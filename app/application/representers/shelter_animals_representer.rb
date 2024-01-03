# frozen_string_literal: true

require_relative 'animal_representer'
require 'roar/decorator'
require 'roar/json'
require 'dry-types'
require 'dry-struct'

module PetAdoption
  module Representer
    # Represents folder summary about repo's folder
    class ShelterAnimals < Roar::Decorator
      include Roar::JSON

      collection :animal_obj_list, extend: Representer::Animal, class: Struct
    end
  end
end
