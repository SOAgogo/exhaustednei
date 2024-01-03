# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module PetAdoption
  module Representer
    # Represents a CreditShare value
    class AnimalFeatures < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :origin_id
      property :species
      property :kind
      property :age
      property :color
      property :sex
      property :sterilized
      property :vaccinated
      property :bodytype
      property :image_url
      property :registration_date

      private

      def origin_id
        represented.origin_id
      end
    end
  end
end
