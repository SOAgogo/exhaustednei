# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'features_representer'

module PetAdoption
  module Representer
    # For animal obj list
    class Animal < Roar::Decorator
      include Roar::JSON

      property :animal, extend: Representer::AnimalFeatures, class: Struct
    end
  end
end
