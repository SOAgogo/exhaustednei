# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'animal_representer'
require_relative 'animal_scores'
module PetAdoption
  module  Representer
    # Represents a CreditShare value
    class AnimalRecommendation < Roar::Decorator
      include Roar::JSON

      property :shelter_name
      property :recommend_animal, extend: Representer::Animal, class: OpenStruct
      property :scores, extend: Representer::AnimalScore, class: OpenStruct
    end
  end
end
