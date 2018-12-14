module Charge
   module Values
      class UploadSpec
         attr :directory
         attr :filename
         attr :key

         attr :file

         attr :allow_overwrite
         attr :do_conversion
         attr :convert_to_jpeg
  
         def initialize directory, filename, file
            @directory = directory
            @filename = filename
            @key = directory + filename

            @file = file

            set_defaults
         end

         def set_allow_overwrite
            @allow_overwrite = true
         end

         def disable_conversion
            @do_conversion = false
         end

         def set_convert_to_jpeg
            @convert_to_jpeg = true
         end

         def reset_extension_to_jpeg
            @filename = @filename.sub(/\.\S{3,4}$/i, '.jpg')
            @key = @directory + @filename
         end

         private
         def set_defaults
            # Do not allow overwriting unless requested
            @allow_overwrite = false
            # Apply default image conversion unless disabled
            @do_conversion = true
            # Do not onvert the uploaded image to JPEG by default
            @convert_to_jpeg = false
         end
      end
   end
end
