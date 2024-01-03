# frozen_string_literal: true

require 'dry-validation'

module PetAdoption
  module Forms
    # Form validation for Github project URL
    class ShelterSelector < Dry::Validation::Contract
      params do
        required(:animal_kind).filled(:string)
        required(:shelter_name).filled(:string)
      end

      rule(:animal_kind) do
        key.failure('must be dog or cat') unless value == 'dog' && value == 'cat'
      end

      rule(:shelter_name) do
        key.failure('must be a valid Taiwan county') unless value.nil?
      end
    end
  end
end
