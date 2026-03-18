require 'values/delete_spec'

module Charge
   module Factories
      class DeleteSpecFactory
         class << self
            def from_params key, is_directory:
               Values::DeleteSpec.new(key, is_directory: is_directory)
            end
         end
      end
   end
end
