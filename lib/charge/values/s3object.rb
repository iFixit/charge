require 'lib/charge/charge'

module Charge
   module Values
      class S3Object
         attr :key

         def initialize key
            set_key key
         end

         def bucket
            return Config.source_bucket
         end

         def set_key key
            @key = key
         end

         def url
            return root_url + @key
         end

         def root_url
           return Config.url_root + bucket + '/'
         end

         def exists_in_s3?
            s3service = Config.s3service.new
            return s3service.exists_in_s3? bucket(), @key
         end

         def describe
            s3service = Config.s3service.new
            return s3service.exists_in_s3? bucket(), @key
         end
      end
   end
end
