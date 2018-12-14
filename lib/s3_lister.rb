require 'aws-sdk-s3'

class S3Lister
   IGNORED_PREFIXES = [
      'pdf',
      'zip',
      'mp4',
      'webm',
      'ogv',
      'mov',
      'ttf',
      'eot',
      'woff',
      'm4v',
      'psd',
      'ogg',
   ]

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

	def find_largest_objects(bucket, prefix, n = 50)
		return find_whole_bucket(bucket, prefix).sort_by { |item|
				item['size']
			}.reject { |item|
				IGNORED_PREFIXES.any? { |ignore_ext|
					/#{ignore_ext}$/i.match(item['key'])
				}
			}.last(n).reverse
	end


   private
   def build_client()
      @s3 = Aws::S3::Client.new(region: @region)
   end

	def find_whole_bucket(bucket, prefix)
		return Enumerator.new do |yielder|
			fetch_next = nil
			loop do
				req = {
					bucket: bucket, # required
					continuation_token: fetch_next,
					prefix: prefix,
				}
				p req
				resp = @s3.list_objects_v2(req)
				resp['contents'].each { |item| yielder << item }
				fetch_next = resp['next_continuation_token']
				puts "fetched #{resp.key_count}... #{fetch_next}"
				raise StopIteration unless fetch_next
			end
		end.lazy
	end
end
