# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module PetAdoption
  module Representer
    # Represents folder summary about repo's folder
    class ShelterTooOldAnimals < Roar::Decorator
      include Roar::JSON

      property :old_animals_number
      property :severity
    end
  end
end
