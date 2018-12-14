require 'charge'

module Charge
   module Values
      class S3Object
         attr :key

         attr :size
         attr :type
         attr :last_modified

         def initialize key
            set_key key
            fetch_metadata
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

         private

         def fetch_metadata
            return unless exists_in_s3?
            s3service = Config.s3service.new
            metadata = s3service.head_object bucket(), @key

            @size = metadata[:content_length]
            @type = metadata[:content_type]
            @last_modified = metadata[:last_modified]
         end
      end
   end
end
