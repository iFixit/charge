require 'net/http'
require 'uri'

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
               delete_uri = URI.parse("https://#{host}/#{key}")
               puts "Sending DELETE to: #{delete_uri}"
               begin
                  response = Net::HTTP.get_response(delete_uri)
                  puts "DELETE response code: #{reponse.code}"
               rescue StandardError => e
                  puts "Delete failed for URI: #{delete_uri}"
                  puts "ERROR: #{e.inspect}"
               end
            end
         end
      end
   end
end
