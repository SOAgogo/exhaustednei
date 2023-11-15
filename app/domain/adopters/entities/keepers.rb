# frozen_string_literal: true

require_relative '../../shelter_animals/entities/animal'
require_relative 'animal_order'
require_relative 'account'

module PetAdoption
  module Entity
    # class Info::adotpers`
    class Keepers < Account
      include Dry.Types
      attribute :animals, Strict::Array.of(Animal)
      attribute :created_at, Strict::String
      attribute :updated_at, Strict::String
    end
  end
end
