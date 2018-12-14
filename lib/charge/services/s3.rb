require 'aws-sdk-s3'

require 'tempfile'

module Charge
   module Services
      class S3
         def initialize
            @region = Config.region
         end

         def download bucket, key
            puts "Downloading #{key}..."
            downloaded_file = Tempfile.new('from_s3')
            resp = client().get_object({
               response_target: downloaded_file.path,
               bucket: bucket,
               key: key
            })
            return downloaded_file
         end

         def upload file, bucket, key
            puts "Uploading '#{key}' to bucket: '#{bucket}'"
            puts "upload is still a noop!"
# Current implementation:
#$secondsInYear = 60 * 60 * 24 * 365;                                    
#$s3sync = 'aws s3 sync';                                                
#$params = "{$dry} --acl public-read " .                                 
# "--cache-control 'public, max-age={$secondsInYear}' --follow-symlinks";
         end

         def exists_in_s3? bucket, key
            s3 = Aws::S3::Resource.new(region: @region)
            s3bucket = s3.bucket(bucket) 
            return s3bucket.object(key).exists?
         end

         def client
            return @s3 unless @s3.nil?
            @s3 = Aws::S3::Client.new(region: @region)
            return @s3
         end
      end

      class S3Stubbed < S3
         def upload file, bucket, key
            puts "UPLOADS STUBBED FOR TESTING!"
         end
      end
   end
end
