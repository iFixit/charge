#require 'lib/charge/references'

require_relative 'references'

class ReferenceFactory
   def initialize bucket_config
      @bucket_config = bucket_config
   end

   def get_source_reference key
      return SourceS3Reference.new(@bucket_config, key)
   end

   def get_live_reference key
      return LiveS3Reference.new(@bucket_config, key)
   end

   def get_metadata_reference key
      return MetadataS3Reference.new(@bucket_config, key)
   end
end
