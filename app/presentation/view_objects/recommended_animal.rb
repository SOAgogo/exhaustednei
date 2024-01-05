# frozen_string_literal: true

module PetAdoption
  module Views
    # View for a recommended animal
    class PromoteUserAnimals
      attr_reader :prefer_animals

      def initialize(result)
        @prefer_animals = PromoteUserAnimals.to_hash(result.recommendation)
      end

      def self.to_hash(result)
        result.map do |animal|
          [
            animal.shelter_name,
            animal.recommend_animal.animal.to_h.transform_keys(&:to_s).except('links'),
            animal.scores.scores
          ]
        end
      end
    end
  end
end
