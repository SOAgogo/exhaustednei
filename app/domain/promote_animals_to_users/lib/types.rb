# frozen_string_literal: true

module PetAdoption
  module Types
    # Hash type that returns empty array when key not found
    class HashedShelters
      def self.new
        Hash.new { |hash, key| hash[key] = [] }
      end
    end
  end
end
