require 'charge'
require 'values/s3reference'

module Charge
   module Values
      # Source reference is the default
      class SourceObject < S3Reference
      end

      # The live reference lives in the live bucket
      class LiveObject < S3Reference
         def bucket
            return Config.live_bucket
         end
      end

      # Metadata is in the source bucket with a prefix added.
      class MetadataObject < S3Reference
         METADATA_PREFIX = 'metadata/'
         def set_key key
            @key = METADATA_PREFIX + key
         end
      end
   end
end
