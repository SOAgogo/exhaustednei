# frozen_string_literal: true

require 'dry-validation'
module PetAdoption
  module Forms
    # Validate user data
    class RecommendInputsValidator < Dry::Validation::Contract
      params do
        required(:age).filled(:string)
        required(:sterilized).filled(:string)
        required(:bodytype).filled(:string)
        required(:sex).filled(:string)
        required(:vaccinated).filled(:string)
        required(:species).filled(:string)
        required(:color).filled(:string)
        required(:ratio_age).filled(:string)
        required(:ratio_sterilized).filled(:string)
        required(:ratio_bodytype).filled(:string)
        required(:ratio_sex).filled(:string)
        required(:ratio_vaccinated).filled(:string)
        required(:ratio_species).filled(:string)
        required(:ratio_color).filled(:string)
        required(:top).filled(:string)
      end
    end
  end
end
