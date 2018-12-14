require 'values/edit_spec'

module Charge
   module Factories
      class EditSpecFactory
         class << self
            def from_form_params params
               key = params[:splat].first
               edit_spec = Values::EditSpec.new(key)

               unless params['size'] == "0"
                  resize = params['size'] == 'custom' ?
                        params['custom-size'].to_i : params['size'].to_i
                  edit_spec.set_resize resize
               end

               quality = params['quality'] == "custom" ?
                  params['custom-quality'].to_i : params['quality'].to_i
               edit_spec.set_quality quality

               return edit_spec
            end
         end
      end
   end
end
