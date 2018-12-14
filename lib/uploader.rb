require_relative 's3manipulations'
require_relative 'streamingout'

class Uploader < S3Manipulations
   include StreamingOutput

   def initialize stream_out, reference_factory
      @stream_out = stream_out
      @reference_factory = reference_factory
   end

   def upload file, directory
      @filename = file[:filename]
      @key = build_key directory, @filename
      stream_msg "Uploading file '#{@key}'!"
      
      handle_upload file

      generate_view_link
   end

   def handle_upload file
      @filesize = file[:tempfile].size
      stream_msg "filename is '#{@filename}' with size of #{@filesize / 1024}K "

      warn_if_large_filesize @filesize

      # testing!
      return testing_handle_upload file 
      
      # Do the thing
      # Put the file to the source bucket
      # Put the file to the live bucket
   end

   def testing_handle_upload file
      stream_msg "Skipping upload for testing!"
      stream_msg "Uploaded image:"
      stream_msg "<img src=\"#{ImageUrl.image_to_url file}\">"
   end

   def generate_view_link
      stream_msg "View new file at <a href=\"/view/#{@key}\">#{@key}</a>"
   end

   def build_key directory, filename
      return directory + filename
   end
end
