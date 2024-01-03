# frozen_string_literal: true

module PetAdoption
  module Representer
    # Represents a list of projects for API output
    class PotentialFinderRepresenter < Roar::Decorator
      include Roar::JSON

      collection :finders, extend: FinderInfoRepresenter, class: Struct
    end
  end
end
