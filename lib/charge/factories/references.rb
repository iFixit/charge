require 'charge'
require 'values/references'

module Charge
   module Factories
      class ReferenceFactory
         class << self
            def source key
               return Values::SourceObject.new key
            end
            def live key
               return Values::LiveObject.new key
            end
            def metadata key
               return Values::MetadataObject.new key
            end
         end
      end
   end
end
