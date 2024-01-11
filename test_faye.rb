require 'net/http'
require 'json'

faye_url = URI.parse('http://localhost:9090/faye')
channel = '/test_channel'
data = { text: 'Hello, Faye!' }

http = Net::HTTP.new(faye_url.host, faye_url.port)
request = Net::HTTP::Post.new(faye_url.path, { 'Content-Type' => 'application/json' })
request.body = { channel: channel, data: data }.to_json

response = http.request(request)

puts "Response from Faye server: #{response.code} #{response.body}"
