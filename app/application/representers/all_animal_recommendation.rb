# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'animal_recommendation'

module PetAdoption
  module  Representer
    # Represents a CreditShare value
    class AllAnimalRecommendation < Roar::Decorator
      include Roar::JSON

      collection :recommendation, extend: Representer::AnimalRecommendation, class: Struct
    end
  end
end
