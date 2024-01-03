# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module PetAdoption
  module Representer
    # Represents a CreditShare value
    class VetRecommeandation < Roar::Decorator
      include Roar::JSON

      collection :clinics, extend: Representer::AnimalClinic, class: Struct
      property :take_care_info
    end
  end
end
