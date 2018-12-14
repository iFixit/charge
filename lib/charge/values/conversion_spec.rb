module Charge
   module Values 
      class ConversionSpec
         DEFAULT_QUALITY = 85

         attr :bounding_box
         attr :quality

         attr :input_file
         attr :output_file

         def initialize input_file, output_file
            @input_file = input_file
            @output_file = output_file
            set_defaults
         end

         def set_bounding_box box_size
            @bounding_box = box_size
         end

         def set_quality quality
            @quality = quality
         end

         private
         def set_defaults
            @bounding_box = nil
            @quality = DEFAULT_QUALITY
         end
      end
   end
end
