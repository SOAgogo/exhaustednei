# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'pry'
require 'json'
require 'yaml'
# verify your identification

begin
  uri = 'https://data.moa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL'
  url = URI(uri)
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request['accept'] = 'application/json'
  response = http.request(request)
  body = JSON.parse(response.read_body)[1..20].to_json
  File.write('spec/fixtures/DogCat_results.json', body)

end
