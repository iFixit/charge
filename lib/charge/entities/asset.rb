require 'values/references'

module Charge
   module Entities
      class Asset
         attr :key

         def initialize key
            @key = key
         end

         def source
            return Values::SourceObject.new @key
         end

         def live
            return Values::LiveObject.new @key
         end

         def metadata
            return Values::MetadataObject.new @key
         end
      end
   end
end
