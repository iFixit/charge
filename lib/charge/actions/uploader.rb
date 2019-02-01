require 'charge'
require 'values/upload_spec'
require 'services/image_converter'
require 'helpers/streaming_output'
require 'helpers/imageurl'

require 'tempfile'

module Charge
   module Actions
      class Uploader
         include Helpers::StreamingOutput
         def initialize upload_spec
            @upload_spec = upload_spec
            @s3 = Config::s3service.new
         end

         def upload
            stream_msg "Uploading file '#{@upload_spec.key}'..."
            check_filesize

            @uploaded_file = @upload_spec.file[:tempfile]
            @new_source_file = prepare_source_file
            @new_live_file = Tempfile.new('new_live_file')

            apply_conversion

            return if already_exists_in_s3?
            upload_to_source
            upload_to_live

            record_metadata

            provide_view_link
         end

         private
         def check_filesize
            filename = @upload_spec.filename
            filesize = @upload_spec.file[:tempfile].size
            stream_msg "filename is '#{filename}' with size of #{filesize / 1024}K "

            return unless filesize > Config::LARGE_FILE_WARNING_LIMIT
            # Do not warn if we are going to recompress
            return if @upload_spec.do_conversion
            # Warn about very large filesize
            filesize_k = filesize / 1024
            large_k = Config::LARGE_FILE_WARNING_LIMIT / 1024
            stream_warning "File size of #{filesize_k}K (> #{large_k}K) is very large for the live site!"
         end

         def already_exists_in_s3?
            return false if @upload_spec.allow_overwrite
            if @s3.exists_in_s3? Config.source_bucket, @upload_spec.key 
               stream_warning "#{@upload_spec.key} already exists in s3!"
               stream_msg "set the 'allow-overwrite' option if needed."
               return true
            end
            return false
         end

         def prepare_source_file
            if @upload_spec.convert_to_jpeg
               stream_msg "Converting new file to JPEG..."
               jpeg_source_file = Tempfile.new('converted.jpg')
               Services::ImageConverter.convert_to_jpeg(
                  @uploaded_file, jpeg_source_file)
               @upload_spec.reset_extension_to_jpeg
               stream_msg "Conversion to JPEG complete!"
               new_size_k = jpeg_source_file.length / 1024 
               stream_msg "New file size after conversion: #{new_size_k}K"
               return jpeg_source_file
            end
            # Use the source file if we're not converting to jpeg
            return @uploaded_file
         end

         def apply_conversion
            if @upload_spec.do_conversion
               convert_image
            else 
               @new_live_file = @new_source_file
            end
         end

         def convert_image
            @conversion = Factories::ConversionSpecFactory.default_conversion(
                  @new_source_file, @new_live_file)
            stream_msg "Applying default image conversion..."
            Services::ImageConverter.convert_image @conversion
            stream_msg "Default image conversion complete!"

            new_size_k = @new_live_file.length / 1024 
            stream_msg "Live file size after default conversion: #{new_size_k}K"
         end

         def upload_to_source
            source_bucket = Config.source_bucket

            stream_msg "displaying uploaded image"
            size_k = @new_source_file.length / 1024 
            stream_msg "File Source File Size: #{size_k}K"
            stream_msg "<img src=\"#{Helpers::ImageUrl.image_to_url 'image', @new_source_file}\">"

            @s3.upload(@new_source_file, source_bucket, @upload_spec.key)
         end

         def upload_to_live
            live_bucket = Config.live_bucket

            stream_msg "displaying new live image"
            size_k = @new_live_file.length / 1024 
            stream_msg "new live file size: #{size_k}k"
            stream_msg "<img src=\"#{Helpers::ImageUrl.image_to_url 'image', @new_live_file}\">"

            @s3.upload(@new_live_file, live_bucket, @upload_spec.key)
         end

         def record_metadata
            return if @conversion.nil?
            stream_msg "Recording conversion metadata..."
            puts "Metadata recording is still a noop..."
         end

         def provide_view_link
            key = @upload_spec.key
            stream_msg "View new file at <a href=\"/view/#{key}\">#{key}</a>"
         end
      end
   end
end
