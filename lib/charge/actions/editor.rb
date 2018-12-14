require 'charge'

require 'values/upload_spec'
require 'services/image_converter'
require 'helpers/streaming_output'
require 'helpers/imageurl'

require 'tempfile'

module Charge
   module Actions
      class Editor
         include Helpers::StreamingOutput
         def initialize edit_spec
            @edit_spec = edit_spec
            @s3 = Config::s3service.new

         end

         def edit
            return unless check_existence
            stream_msg "Editting image #{@edit_spec.key}"

            @source_image = pull_image_from_source
            @new_live_image = Tempfile.new('new_live_image')

            run_conversion 
            upload_converted_file

            record_metadata
            provide_view_link
         end

         private
         def check_existence
            return true if @s3.exists_in_s3? Config.source_bucket, @edit_spec.key 
            stream_warning "Source image #{@edit_spec.key} does not exist in s3!"
            stream_warning "Aborting..."
            return false
         end

         def pull_image_from_source
            stream_msg "Pulling source image from S3..."
            source_image = @s3.download Config.source_bucket, @edit_spec.key
            stream_msg "Fetched #{source_image.length / 1024}K from S3..."
            return source_image
         end
  
         def run_conversion
            stream_msg "Running Conversion process..."
            @conversion = Factories::ConversionSpecFactory.build(
                        @source_image, @new_live_image, @edit_spec)

            stream_msg "Applying image conversion..."
            Services::ImageConverter.convert_image @conversion
            stream_msg "Image conversion complete!"

            new_size_k = @new_live_image.length / 1024 
            stream_msg "Live file size after conversion: #{new_size_k}K"
         end

         def upload_converted_file
            live_bucket = Config.live_bucket

            stream_warning "Uploading to the live ifixit-assets bucket is a no-op!"
            stream_msg "Displaying image instead!"
            size_k = @new_live_image.length / 1024 
            stream_msg "New Live File size: #{size_k}K"
            stream_msg "<img src=\"#{Helpers::ImageUrl.image_to_url 'image', @new_live_image}\">"

            #@s3.upload(@new_live_image, live_bucket, @upload_spec.key)
         end

         def record_metadata
            stream_msg "Recording edit metadata..."
            puts "Metadata recording is still a noop..."
         end

         def provide_view_link
            key = @edit_spec.key
            stream_msg "View converted image at: <a href=\"/view/#{key}\">#{key}</a>"
         end
      end
   end
end
