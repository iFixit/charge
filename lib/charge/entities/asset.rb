require 'values/references'

module Charge
   module Entities
      class Asset
         attr :key

         def initialize key
            @key = key
         end

         def source
            @source ||= Values::SourceObject.new @key
            return @source
         end

         def live
            @live ||= Values::LiveObject.new @key
            return @live
         end

         def metadata
            @metadata ||= Values::MetadataObject.new @key
            return @metadata
         end
      end
   end
end
