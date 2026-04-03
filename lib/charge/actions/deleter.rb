require 'charge'
require 'helpers/streaming_output'
require 'services/cache_buster'

module Charge
   module Actions
      class Deleter
         include Helpers::StreamingOutput
         def initialize delete_spec
            @delete_spec = delete_spec
            @s3 = Config::s3service.new
         end

         def delete
            if @delete_spec.is_directory
               delete_directory
            else
               delete_single_file
            end
            provide_browse_link
         end

         private
         def delete_single_file
            key = @delete_spec.key
            stream_msg "Deleting file '#{key}'..."
            @s3.delete(Config.source_bucket, key)
            stream_msg "Deleted from source bucket."
            @s3.delete(Config.live_bucket, key)
            stream_msg "Deleted from live bucket."
            Services::CacheBuster.bust_cache_on_hosts key
            stream_msg "Cache busted for '#{key}'."
         end

         def delete_directory
            prefix = @delete_spec.key
            stream_msg "Deleting all files under '#{prefix}'..."
            keys = @s3.all_keys_under(Config.live_bucket, prefix)
            count = 0
            keys.each do |key|
               count += 1
               stream_msg "Deleting file #{count}: #{key}..."
               @s3.delete(Config.source_bucket, key)
               @s3.delete(Config.live_bucket, key)
               Services::CacheBuster.bust_cache_on_hosts key
            end
            stream_msg "Deleted #{count} file(s)."
         end

         def provide_browse_link
            key = @delete_spec.key
            parent = parent_directory(key)
            stream_msg %Q(Back to <a href="/browse/#{parent}">#{parent}</a>)
         end

         def parent_directory key
            parts = key.chomp('/').split('/')
            parts.pop
            return Config.base_prefix if parts.empty?
            parts.join('/') + '/'
         end
      end
   end
end
