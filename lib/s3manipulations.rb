require_relative 'imageurl'

class S3Manipulations
   LARGE_FILE_WARNING_LIMIT = 1024**2 # 1MB

   def warn_if_large_filesize filesize
      if filesize > LARGE_FILE_WARNING_LIMIT
         stream_warning "File size of #{filesize / 1024}K (> #{LARGE_FILE_WARNING_LIMIT / 1024}K) is very large for the live site!"
      end
   end

   def get_client
   end
end
