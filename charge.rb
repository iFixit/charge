require 'sinatra'

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'lib/charge/charge'

require 'lib/charge/factories/upload_spec_factory'
require 'lib/charge/factories/edit_spec_factory'
require 'lib/charge/factories/references'


# Old requires
require './lib/references'

require './lib/charge_config'
require './lib/reference_factory'

SOURCE_BUCKET='ifixit-static-source'
LIVE_BUCKET='ifixit-assets'

S3_URL_ROOT = 'https://s3.amazonaws.com/'

BASE_PREFIX='static/'

Charge::Config.set_buckets SOURCE_BUCKET, LIVE_BUCKET
Charge::Config.set_url_root S3_URL_ROOT
Charge::Config.set_base_prefix BASE_PREFIX

Charge::Config.stub_uploads # !!!

config = ChargeConfig.new SOURCE_BUCKET, LIVE_BUCKET
config.set_url_root S3_URL_ROOT

reference_factory = ReferenceFactory.new config
references = Charge::Factories::ReferenceFactory

helpers do
   def get_parent_dir directory
      paths = directory.split('/')
      paths.pop
      return BASE_PREFIX if paths.empty?
      return paths.join('/') + '/'
   end
   def enforce_static_prefix path
      unless /^#{BASE_PREFIX}/.match(path)
         halt 400, "You can only browse #{BASE_PREFIX}"
      end
   end
end

get '/browse/*' do
   @directory = params[:splat].first
   @parent_directory = get_parent_dir @directory
   enforce_static_prefix @directory
   s3service = Charge::Config.s3service.new()
   @items = s3service.items_in_bucket(LIVE_BUCKET, @directory)
   erb :browse
end

get '/view/*' do
   @key = params[:splat].first
   enforce_static_prefix @key
   @parent_directory = get_parent_dir @key
   @source_reference = reference_factory.get_source_reference @key
   @live_reference = reference_factory.get_live_reference @key
   @metadata_reference = reference_factory.get_metadata_reference @key
   erb :view
end

get '/edit/*' do
   @key = params[:splat].first
   enforce_static_prefix @key
   @source_reference = reference_factory.get_source_reference @key
   @live_reference = reference_factory.get_live_reference @key
   @metadata_reference = reference_factory.get_metadata_reference @key
   erb :edit
end

post '/edit-handler/*' do
   edit_spec = Charge::Factories::EditSpecFactory::from_form_params params
   enforce_static_prefix edit_spec.key
   stream do |output|
      editor = Charge::Actions::Editor.new edit_spec
      editor.set_output_stream output
      editor.edit
   end
end

get '/upload/*' do
   @directory = params[:splat].first
   enforce_static_prefix @directory
   erb :upload
end

post '/upload-handler/*' do
   upload_spec = Charge::Factories::UploadSpecFactory::from_form_params params
   enforce_static_prefix upload_spec.key
   stream do |output|
      uploader = Charge::Actions::Uploader.new upload_spec
      uploader.set_output_stream output
      uploader.upload
   end
end

get '/restore-original/*' do
   @key = params[:splat].first
   enforce_static_prefix @key
   'sorry, restoration not yet implemented'
end

get '/worst' do
   s3service = Charge::Config.s3service.new()
   @biggest = s3service.find_largest_objects(LIVE_BUCKET, BASE_PREFIX, 100)
   erb :worst
end

get '/' do
   redirect '/browse/' + BASE_PREFIX
end
