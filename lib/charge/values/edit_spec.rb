require 'lib/charge/factories/conversion_spec_factory'

module Charge
   module Values
      class EditSpec
         attr :key
         attr :resize
         attr :bounding_box
         attr :quality

         def initialize key
            @key = key
            set_defaults
         end

         def set_resize bounding_box
            # raise unless (1..4096).include? bounding_box
            @resize = true
            @bounding_box = bounding_box
         end

         def set_quality quality
            # raise unless (40..100).include? quality
            @quality = quality
         end

         private
         def set_defaults
            @resize = false
         end
      end
   end
end
