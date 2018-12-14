require 'base64'

module Charge
   module Helpers
      class ImageUrl
         def self.image_to_url type, file
            return "data:#{type};base64,#{Base64.encode64(file.read)}"
         end
      end
   end
end
