require 'aws-sdk-s3'

class S3Lister
   def initialize(region='us-east-1')
      @region = region
      build_client
   end

   def items_in_bucket(bucket, prefix)
      resp = @s3.list_objects_v2({
        bucket: bucket, # required
        delimiter: '/',
        #max_keys: 1000, # ???
        prefix: prefix,
      })
      return resp
   end

   private
   def build_client()
      @s3 = Aws::S3::Client.new(region: @region)
   end
end
