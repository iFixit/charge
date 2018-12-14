require_relative 's3manipulations'

EditSpec = Struct.new()

class Editor < S3Manipulations
   include StreamingOutput
   def initialize stream_out, reference_factory
      @stream_out = stream_out
      @reference_factory = reference_factory
   end

   def edit key
   end
end
