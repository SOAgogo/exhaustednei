# frozen_string_literal: true

require 'dry-validation'
module PetAdoption
  module Forms
    # Validate user data
    class FinderInputsValidator < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        required(:email).filled(:string)
        required(:phone).filled(:string)
        required(:county).filled(:string)
        required(:location).filled(:string)
        required(:file).filled(:string)
        required(:number).filled(:string)
        required(:distance).filled(:string)
      end
    end
  end
end
