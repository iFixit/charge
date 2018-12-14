require 'lib/charge/values/upload_spec'

module Charge
   module Factories
      class UploadSpecFactory
         class << self
            def from_form_params params
               directory = params[:splat].first
               file = params[:file]
               filename = file[:filename]
               upload_spec = Values::UploadSpec.new(
                     directory,
                     filename,
                     file)
               if params["allow_overwrite"] == "on"
                  upload_spec.set_allow_overwrite
               end
               unless params["default_conversion"] == "on"
                  upload_spec.disable_conversion
               end
               if params["convert_to_jpeg"] == "on"
                  upload_spec.set_convert_to_jpeg
               end
               return upload_spec
            end
         end
      end
   end
end
