# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'pry'
require 'json'
require 'yaml'
# verify your identification
require_relative 'shelter'
require_relative 'animal'
require_relative 'util'
module Info
  # class Info::Project`
  class Project
    attr_reader :request_body, :shelter_list

    def initialize(request_body)
      @request_body = request_body
      @shelter_list = nil
    end

    def self.setup_url(uri)
      url = URI(uri)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      [url, http]
    end

    def self.connection(uri)
      url, http = setup_url(uri)
      request = Net::HTTP::Get.new(url)
      request['accept'] = 'application/json'
      response = http.request(request)
      JSON.parse(response.read_body)[1..20]
    end

    def initiate_shelterlist
      @shelter_list = ShelterList.new
      @request_body.each do |hash_value|
        # animal_data = Util.parser(hash_value)
        animal_data = Util::Util.animal_parser(hash_value)
        shelter_data = Util::Util.shelter_parser(hash_value)
        shelter_initiator(animal_data, shelter_data)
        # @shelter_list = shelter_initiator(@shelter_list, animal_data, shelter_data)
      end
      # @shelter_list
    end

    def update_shelter(animal_data, shelter_data)
      shelter = @shelter_list.get_the_shelter(shelter_data['animal_shelter_pkid'])
      shelter = Shelter.new if shelter.nil?
      Util::Util.animal_classifier(shelter, animal_data)
    end

    def shelter_initiator(animal_data, shelter_data)
      shelter = update_shelter(animal_data, shelter_data)
      @shelter_list.shelter_hash[shelter_data['animal_shelter_pkid']] = shelter
    end
  end
end
