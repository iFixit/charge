module Charge
   module Helpers
      module StreamingOutput
         def set_output_stream stream
            @output_stream = stream
         end

         private
         def stream_msg msg
            put_stream "<p>#{msg}<p>" 
         end
         
         def stream_warning warning 
            put_stream "<p><b>(!!!) WARNING: #{warning} (!!!)</b><p>"
         end

         def put_stream str
            @output_stream << str unless @output_stream.nil?
         end
      end
   end
end
