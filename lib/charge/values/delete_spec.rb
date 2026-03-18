module Charge
   module Values
      class DeleteSpec
         attr :key
         attr :is_directory

         def initialize key, is_directory: false
            @key = key
            @is_directory = is_directory
         end
      end
   end
end
