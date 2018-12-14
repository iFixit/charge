require 'lib/charge/charge'
require 'lib/charge/values/s3object'

module Charge
   module Values
      # Source object is the default
      class SourceObject < S3Object
      end

      # The live object lives in the live bucket
      class LiveObject < S3Object
         def bucket
            return Config.live_bucket
         end
      end

      # Metadata is in the source bucket with a prefix added.
      class MetadataObject < S3Object
         METADATA_PREFIX = 'metadata/'
         def set_key key
            @key = METADATA_PREFIX + key
         end
      end
   end
end
