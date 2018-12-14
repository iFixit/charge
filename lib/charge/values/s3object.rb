require 'lib/charge/charge'

module Charge
   module Values
      class S3Object
         attr :key

         def initialize image_link
            set_ket image_link.key
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
      end
   end
end
