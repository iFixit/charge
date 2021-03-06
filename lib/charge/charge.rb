$LOAD_PATH.unshift File.dirname(__FILE__)

require 'services/s3'

require 'actions/uploader'
require 'actions/editor'

require 'exceptions'

module Charge
   # Charge Configuration Singleton
   class Config
      LARGE_FILE_WARNING_LIMIT = 1024**2 # 1MB
      @region = 'us-east-1'
      @s3service = Services::S3
      class << self
         attr_reader :region
         attr_reader :s3service

         attr_reader :source_bucket
         attr_reader :live_bucket

         attr_reader :url_root
         attr_reader :base_prefix

         attr_reader :hosts_to_cache_bust

         def set_buckets source_bucket, live_bucket
            @source_bucket = source_bucket
            @live_bucket = live_bucket
         end

         def set_url_root url_root
            @url_root = url_root
         end

         def set_base_prefix base_prefix
            @base_prefix = base_prefix
         end

         def stub_uploads
            @s3service = Services::S3Stubbed
         end

         def set_hosts_to_cache_bust hosts_list
            @hosts_to_cache_bust = hosts_list
         end
      end
   end
end
