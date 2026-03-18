require 'sinatra'

set :bind, '0.0.0.0'
set :port, ENV['CHARGE_PORT'] || 4567

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'lib/charge/charge'

require 'lib/charge/entities/asset'

require 'lib/charge/factories/upload_spec_factory'
require 'lib/charge/factories/edit_spec_factory'
require 'lib/charge/factories/delete_spec_factory'

SOURCE_BUCKET='ifixit-static-source'
LIVE_BUCKET='ifixit-assets'

S3_URL_ROOT = 'https://s3.amazonaws.com/'

BASE_PREFIX='static/'

Charge::Config.set_buckets SOURCE_BUCKET, LIVE_BUCKET
Charge::Config.set_url_root S3_URL_ROOT
Charge::Config.set_base_prefix BASE_PREFIX

hosts_to_cache_bust = (ENV['HOSTS_TO_CACHE_BUST'] || '').split(',')
Charge::Config.set_hosts_to_cache_bust hosts_to_cache_bust

Charge::Config.stub_uploads unless ENV['ENABLE_S3_UPLOADS'] == 'true'

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
   key = params[:splat].first
   enforce_static_prefix key
   @parent_directory = get_parent_dir key
   @asset = Charge::Entities::Asset.new key
   erb :view
end

get '/edit/*' do
   key = params[:splat].first
   enforce_static_prefix key
   @asset = Charge::Entities::Asset.new key
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
   halt 400, "you must choose a file to upload!" if params[:file].nil?
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
   @asset = Charge::Entities::Asset.new @key
   'sorry, restoration not yet implemented'
end

get '/bulk-upload/*' do
   @directory = params[:splat].first
   enforce_static_prefix @directory
   @bulk = true
   erb :upload
end

post '/bulk-upload-handler/*' do
   halt 400, "you must choose files to upload!" if params[:files].nil? || params[:files].empty?
   upload_specs = Charge::Factories::UploadSpecFactory::from_form_params_bulk params
   upload_specs.each { |spec| enforce_static_prefix spec.key }
   stream do |output|
      bulk_uploader = Charge::Actions::BulkUploader.new upload_specs
      bulk_uploader.set_output_stream output
      bulk_uploader.upload
   end
end

get '/delete/*' do
   @key = params[:splat].first
   enforce_static_prefix @key
   @is_directory = false
   @parent_directory = get_parent_dir @key
   erb :delete_confirm
end

get '/delete-dir/*' do
   @key = params[:splat].first
   enforce_static_prefix @key
   @is_directory = true
   @parent_directory = get_parent_dir @key
   s3service = Charge::Config.s3service.new()
   @affected_keys = s3service.all_keys_under(LIVE_BUCKET, @key)
   erb :delete_confirm
end

post '/delete-handler/*' do
   key = params[:splat].first
   enforce_static_prefix key
   is_directory = params['is_directory'] == 'true'
   delete_spec = Charge::Factories::DeleteSpecFactory::from_params(key, is_directory: is_directory)
   stream do |output|
      deleter = Charge::Actions::Deleter.new delete_spec
      deleter.set_output_stream output
      deleter.delete
   end
end

get '/worst' do
   s3service = Charge::Config.s3service.new()
   @biggest = s3service.find_largest_objects(LIVE_BUCKET, BASE_PREFIX, 100)
   erb :worst
end

get '/' do
   redirect '/browse/' + BASE_PREFIX
end
