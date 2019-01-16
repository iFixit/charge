module Charge
   module Services
      class CacheBuster
         class << self
            def bust_cache_on_hosts key
               return if Config.hosts_to_cache_bust.nil?
               Config.hosts_to_cache_bust.each do |host|
                  self.bust_cache_on_host host, key
               end
            end

            def bust_cache_on_host host, key
               puts "Cache bust '#{key}' on host '#{host}'"
            end
         end
      end
   end
end
