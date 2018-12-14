require 'lib/charge/charge'
require 'lib/charge/values/references'

module Charge
   module Factories
      class ReferenceFactory
         class << self  
            def source image_link
               return Values::SourceObject.new image_link               
            end
            def live image_link
               return Values::LiveObject.new image_link               
            end
            def metadata image_link
               return Values::MetadataObject.new image_link               
            end
         end
      end   
   end
end
