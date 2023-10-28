# frozen_string_literal: true

require_relative 'shelter'
require_relative 'animal'
# util handle the parser and other methods
module Util
  # class Info::ShelterList`
  class Util
    def self.animal_parser(data)
      animal_data_hash = {}
      data.each do |key, value|
        animal_data_hash[key] = value unless %w[animal_area_pkid shelter_name shelter_address
                                                shelter_tel].include?(key)
      end
      animal_data_hash
    end

    def self.shelter_parser(data)
      animal_data_hash = {}
      data.each do |key, value|
        animal_data_hash[key] = value unless %w[animal_area_pkid shelter_name shelter_address
                                                shelter_tel].include?(key)
      end
      animal_data_hash
    end

    def self.put_the_animal_into_shelter(shelter, animal_obj)
      shelter.animal_object_hash[animal_obj.animal_id] = animal_obj
      if animal_obj.animal_kind == '狗'
        shelter.set_dog_number
      else
        shelter.set_cat_number
      end
      shelter
    end

    def self.animal_classifier(shelter, animal_data)
      animal = animal_data['animal_kind'] == '狗' ? Info::Dog.new(animal_data) : Info::Cat.new(animal_data)
      Util.put_the_animal_into_shelter(shelter, animal)
      shelter
    end
  end
end
