class ChargeConfig
   attr_reader :source_bucket
   attr_reader :live_bucket

   attr_reader :url_root

   def initialize source_bucket, live_bucket
      @source_bucket = source_bucket
      @live_bucket = live_bucket
   end

   def set_url_root url_root
      @url_root = url_root
   end
end
