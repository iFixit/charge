require 'values/conversion_spec'
require 'values/edit_spec'

module Charge
   module Factories
      class ConversionSpecFactory
         class << self
            def default_conversion input_file, output_file
               return Values::ConversionSpec.new(
                     input_file, output_file)
            end

            def build input_file, output_file, edit_spec
               conversion_spec = Values::ConversionSpec.new(
                     input_file, output_file)

               if edit_spec.resize
                  conversion_spec.set_bounding_box edit_spec.bounding_box
               end
               
               unless edit_spec.quality.nil?   
                  conversion_spec.set_quality edit_spec.quality
               end

               return conversion_spec
            end
         end
      end
   end
end
