# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module PetAdoption
  module Representer
    # Represents a CreditShare value
    class AnimalClinic < Roar::Decorator
      include Roar::JSON

      property :name
      property :open_time
      property :which_road
      property :address
      property :longitude
      property :latitude
      property :rating
      property :total_ratings
    end
  end
end
