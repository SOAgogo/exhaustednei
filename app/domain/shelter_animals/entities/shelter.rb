# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require_relative 'animal'
module PetAdoption
  module Entity
    # class Info::Shelter`
    class Shelter
      def initialize(shelter_info)
        @shelter_info = Value::ShelterInfo.new(shelter_info)
        @animal_object_list = Types::HashedArrays.new
      end

      def promote_to_user
        animal_object_list.values.map(&:promote_to_user)
      end

      def show_the_chart
        animal_object_list.values.map(&:show_the_chart)
      end
    end
  end
end
