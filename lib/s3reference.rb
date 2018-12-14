require 'aws-sdk-s3'

class S3Reference
   attr :config
   attr :key
   attr :region

   def initialize(config, key, region='us-east-1')
      @config = config
      @region = region
      set_key key
   end

   def data
      return @data unless @data.nil?
      @data = fetch_object_data
      return @data
   end

   def set_key key
      @key = key
   end

   def get_bucket
      return @config.source_bucket
   end

   def url
      return root_url + @key
   end

   def root_url
     return @config.url_root + get_bucket + '/'
   end

   def exists_in_s3?
      s3 = Aws::S3::Resource.new(region: @region)
      bucket = s3.bucket(get_bucket) 
      return bucket.object(@key).exists?
   end

   def fetch_object_data
      puts "Building client.."
      s3 = Aws::S3::Client.new(region: @region)
      p "Built client #{s3}"
      resp = s3.head_object({
         bucket: get_bucket, 
         key: @key,
      })
      return resp.to_h
   end
end
