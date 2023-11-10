# frozen_string_literal: true

require 'pry'
require_relative '../entities/shelter'
require_relative '../entities/animal'

module PetAdoption
  module Info
    # we should create more than one shelterMapper objects?

    # class Info::ShelterMapper`
    class ShelterMapper
      attr_reader :shelter_info_list

      # store the shelter hash that can access shelter object
      @shelter_obj_map = {}
      def initialize(shelter_info_list)
        @shelter_info_list = shelter_info_list
      end

      class << self
        attr_reader :shelter_obj_map
      end

      def self.set_shelter_obj_map(shelter_id, shelter_obj)
        ShelterMapper.shelter_obj_map[shelter_id] = shelter_obj
      end

      def self.get_shelter_obj(shelter_id)
        ShelterMapper.shelter_obj_map[shelter_id]
      end

      def self.shelter_size
        ShelterMapper.shelter_obj_map.size
      end

      def create_all_shelter_animal_obj(shelter_animal_map)
        @shelter_info_list.each do |shelter_info|
          shelter_id = shelter_info['animal_shelter_pkid']
          ShelterMapper.set_shelter_obj_map(shelter_id,
                                            ShelterMapper.find(shelter_info, shelter_animal_map[shelter_id]))
          # end
        end
      end

      def self.calculate_dog_nums
        num = 0
        ShelterMapper.shelter_obj_map.each do |_, shelter_obj|
          num += shelter_obj.dog_number
        end
        num
      end

      def self.calculate_cat_nums
        num = 0
        ShelterMapper.shelter_obj_map.each do |_, shelter_obj|
          num += shelter_obj.cat_number
        end
        num
      end

      def self.find_animal_in_shelter(shelter_id, animal_id)
        ShelterMapper.shelter_obj_map[shelter_id].animal_object_list[animal_id]
      end

      def self.animal_size_in_shelter(rand_shelter_id)
        ShelterMapper.shelter_obj_map[rand_shelter_id].animal_number
      end

      def self.find(shelter_info, animal_map)
        DataMapper.new(shelter_info, animal_map).build_entity
        # @shelter_object_list[shelter_obj.animal_area_pkid] = shelter_obj

        # @animal_object_hash[animal_obj.animal_id] = animal_obj
      end

      # # ShelterMapper::DataMapper
      class DataMapper
        def initialize(shelter_data, animal_map)
          @data = shelter_data
          @animal_map = animal_map
        end

        # rubocop:disable Metrics/MethodLength
        def build_entity
          Entity::Shelter.new(
            # @animal_attributes
            id:,
            animal_shelter_pkid:,
            shelter_name:,
            shelter_address:,
            shelter_tel:,
            animal_object_list:,
            cat_number:,
            dog_number:,
            animal_number:
          )
        end

        # rubocop:enable Metrics/MethodLength
        private

        # def animal_area_pkid
        #   @data['animal_area_pkid']
        # end
        def id
          rand(1..1000)
        end

        def animal_shelter_pkid
          @data['animal_shelter_pkid']
        end

        def shelter_name
          @data['shelter_name']
        end

        def shelter_address
          @data['shelter_address']
        end

        def shelter_tel
          @data['shelter_tel']
        end

        def animal_object_list
          @animal_map
        end

        def cat_number
          sum = 0
          @animal_map.each do |_, animal_obj|
            sum += 1 if animal_obj.instance_of?(::Entity::Cat)
          end
          sum
        end

        def dog_number
          sum = 0
          @animal_map.each do |_, animal_obj|
            sum += 1 if animal_obj.instance_of?(::Entity::Dog)
          end
          sum
        end

        def animal_number
          @animal_map.size
        end
      end
    end
  end
end
