# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module PetAdoption
  module Representer
    # Represents a CreditShare value
    class AnimalScore < Roar::Decorator
      include Roar::JSON

      property :scores
    end
  end
end
