require_relative 's3reference'

class SourceS3Reference < S3Reference
end

class LiveS3Reference < S3Reference
   def get_bucket
      return @config.live_bucket
   end
end

class MetadataS3Reference < S3Reference
   def set_key key
      @key = 'metadata/' + key
   end
end
