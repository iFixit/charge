module StreamingOutput
   def stream_msg msg
      @stream_out << "<p>#{msg}<p>"
   end
   
   def stream_warning warning 
      @stream_out << "<p><b>(!!!) WARNING: #{warning} (!!!)</b><p>"
   end
end
