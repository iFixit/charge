require 'charge'

module Charge
   module Values
      class S3Reference
         attr :key

         attr :size
         attr :type

         attr :last_modified
         attr :cache_control
         attr :etag

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

         def uncached_url
            return url + '?' + Time.new.to_i.to_s
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
            @cache_control = metadata[:cache_control]
            @etag = metadata[:etag]
         end
      end
   end
end
