# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'pry'
require 'json'
require 'yaml'
# verify your identification

module Info
  # class Info::ShelterList`
  class ShelterList
    attr_reader :shelter_hash

    def initialize
      @shelter_hash = {}
    end

    def set_shelter_hash
      @shelter_hash
    end

    def howmanyshelters
      @shelter_hash.size
    end

    def calculate_dog_nums
      # obj is a shelter object
      sum = 0
      @shelter_hash.each do |_, obj|
        sum += obj.dog_number
      end
      sum
    end

    def calculate_cat_nums
      # obj is a shelter object
      sum = 0
      @shelter_hash.each do |_, obj|
        sum += obj.cat_number
      end
      sum
    end

    def get_the_shelter(animal_area_pkid)
      @shelter_hash[animal_area_pkid]
    end
  end

  # class Info::Shelter`
  class Shelter
    # attr_reader :animal_id, :animal_area_pkid, :animal_shelter_pkid, :shelter_name, :shelter_address, :shelter_tel

    attr_reader :animal_object_hash, :cat_number, :dog_number

    def initialize
      @animal_object_hash = {}

      @cat_number = 0
      @dog_number = 0
    end

    def set_animal_object_hash
      @animal_object_hash
    end

    def set_cat_number
      @cat_number += 1
    end

    def set_dog_number
      @dog_number += 1
    end

    def animal_nums
      @animal_object_hash.size
    end
  end
end
