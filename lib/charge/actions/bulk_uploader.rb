require 'charge'
require 'actions/uploader'
require 'helpers/streaming_output'

module Charge
   module Actions
      class BulkUploader
         include Helpers::StreamingOutput
         def initialize upload_specs
            @upload_specs = upload_specs
         end

         def upload
            total = @upload_specs.length
            stream_msg "Starting bulk upload of #{total} file(s)..."
            @upload_specs.each_with_index do |spec, index|
               stream_msg "<hr>"
               stream_msg "<b>File #{index + 1} of #{total}: #{spec.filename}</b>"
               uploader = Actions::Uploader.new spec
               uploader.set_output_stream @output_stream
               uploader.upload
            end
            stream_msg "<hr>"
            stream_msg "Bulk upload complete! #{total} file(s) processed."
         end
      end
   end
end
