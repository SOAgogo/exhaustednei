# frozen_string_literal: true

require_relative 'animal_clinic'
require 'roar/decorator'
require 'roar/json'
require 'dry-types'
require 'dry-struct'

module PetAdoption
  module Representer
    # Represents a CreditShare value
    class VetRecommeandation < Roar::Decorator
      include Roar::JSON

      collection :clinics, extend: Representer::AnimalClinic, class: OpenStruct
      property :take_care_info
    end
  end
end
