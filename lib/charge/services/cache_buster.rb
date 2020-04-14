require 'net/http'
require 'uri'
require 'openssl'

module Charge
   module Services
      class CacheBuster
         class << self
            def bust_cache_on_hosts key
               Config.hosts_to_cache_bust.each do |host|
                  self.bust_cache_on_host host, key
               end
            end

            def bust_cache_on_host host, key
               puts "Cache bust '#{key}' on host '#{host}'"
               delete_uri = URI.parse("https://#{host}/#{key}")
               puts "Sending DELETE to: #{delete_uri}"
               request = Net::HTTP::Delete.new(delete_uri)
               req_options = {
                  use_ssl: delete_uri.scheme == "https",
                  verify_mode: OpenSSL::SSL::VERIFY_NONE,
               }
               begin
                  response = Net::HTTP.start(delete_uri.hostname,
                        delete_uri.port, req_options) do |http|
                     http.request(request)
                  end
                  puts "DELETE response code: #{response.code}"
               rescue StandardError => e
                  puts "Delete failed for URI: #{delete_uri}"
                  puts "ERROR: #{e.inspect}"
               end
            end
         end
      end
   end
end
