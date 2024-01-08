# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module PetAdoption
  module Representer
    # Represents folder summary about repo's folder
    class ShelterCrowdedness < Roar::Decorator
      include Roar::JSON

      property :crowdedness
    end
  end
end
