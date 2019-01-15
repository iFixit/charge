require 'values/upload_spec'

module Charge
   module Factories
      class UploadSpecFactory
         class << self
            def from_form_params params
               directory = params[:splat].first
               directory = ensure_ends_in_slash(directory)
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

            def ensure_ends_in_slash directory
               directory_without_slashes = directory.sub(/\/+$/, '')
               directory_ending_in_slash = directory_without_slashes + '/'
               return directory_ending_in_slash
            end
         end
      end
   end
end
