# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require_relative '../../shelter_animals/entities/animal'

module PetAdoption
  module Entity
    # class Info::adotpers`
    class Keepers
      def initialize(animal_info, accounts = PetAdoption::Entity::Accounts.new)
        @accounts = accounts
        @animal_info = animal_info
      end

      def to_attr_hash
        to_hash.except(:address)
      end
    end
  end
end
