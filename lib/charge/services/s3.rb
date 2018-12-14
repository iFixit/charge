require 'aws-sdk-s3'

require 'tempfile'

module Charge
   module Services
      class S3
         # Used to filter large objects list
         IGNORED_LARGE_OBJECT_EXTS = [
            'pdf',
            'zip',
            'mp4',
            'webm',
            'ogv',
            'mov',
            'ttf',
            'eot',
            'woff',
            'm4v',
            'psd',
            'ogg',
         ]

         def initialize
            @region = Config.region
         end

         def items_in_bucket(bucket, prefix)
            resp = client().list_objects_v2({
              bucket: bucket, # required
              delimiter: '/',
              #max_keys: 1000, # ???
              prefix: prefix,
            })
            return resp
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

         def head_object bucket, key
            resp = client().head_object({
               bucket: bucket,
               key: key,
            })
            return resp.to_h
         end

         def find_largest_objects(bucket, prefix, n = 50)
            return find_whole_bucket(bucket, prefix).sort_by { |item|
                  item['size']
               }.reject { |item|
                  IGNORED_LARGE_OBJECT_EXTS.any? { |ignore_ext|
                     /#{ignore_ext}$/i.match(item['key'])
                  }
               }.last(n).reverse
         end

         private

         def client
            return @s3 unless @s3.nil?
            @s3 = Aws::S3::Client.new(region: @region)
            return @s3
         end

         def find_whole_bucket(bucket, prefix)
            return Enumerator.new do |yielder|
               fetch_next = nil
               loop do
                  req = {
                     bucket: bucket, # required
                     continuation_token: fetch_next,
                     prefix: prefix,
                  }
                  resp = client().list_objects_v2(req)
                  resp['contents'].each { |item| yielder << item }
                  fetch_next = resp['next_continuation_token']
                  puts "fetched #{resp.key_count}... #{fetch_next}"
                  raise StopIteration unless fetch_next
               end
            end.lazy
         end
      end

      class S3Stubbed < S3
         def upload file, bucket, key
            puts "UPLOADS STUBBED FOR TESTING!"
         end
      end
   end
end
