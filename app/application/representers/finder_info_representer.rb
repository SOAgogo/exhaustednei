# frozen_string_literal: true

module PetAdoption
  module Representer
    # finder info
    class FinderInfoRepresenter < Roar::Decorator
      include Roar::JSON

      property :name
      property :phone
      property :email
      property :county
      property :species
      property :s3_image_url
      property :longtitude
      property :latitude
      property :distance
    end
  end
end
