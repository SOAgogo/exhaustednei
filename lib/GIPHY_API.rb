# frozen_string_literal: true

require 'net/http'
require 'json'
require 'yaml'

keyword = 'ive'
config = YAML.safe_load_file('../config/secrets.yml')

def make_giphy_request(path, config)
  base_url = 'http://api.giphy.com/v1'
  full_url = "#{base_url}/#{path}api_key=#{config['GIPHY_TOKEN']}"
  response = Net::HTTP.get_response(URI.parse(full_url))
  if response.code == '200'
    JSON.parse(response.body)
  else
    puts "HTTP request fail: #{response.code}"
    nil
  end
end

result_search = make_giphy_request("gifs/search?q=#{keyword}&limit=5&", config)
result_suggest = make_giphy_request("tags/related/#{keyword}?", config)

name_list = result_suggest['data'].first(5).map { |item| item['name'] }
sg_results = { 'related' => name_list }

sc_results = []
result_search['data'].map do |gif|
  temp = {}
  temp['url'] = gif['url']
  temp['title'] = gif['title']
  temp['height'] = gif['images']['original']['height']
  temp['width'] = gif['images']['original']['width']
  sc_results << temp
end

sc_results.push(sg_results)
File.write('../spec/fixtures/giphy_results.yml', sc_results.to_yaml)
