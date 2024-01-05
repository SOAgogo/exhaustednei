# frozen_string_literal: true

# Purpose: View object for a vets
module PetAdoption
  module Views
    # View for a vets
    class LossingPets
      attr_reader :lossing_pets_info

      def initialize(result)
        @lossing_pets_info = merge(result.finders)
      end

      def merge(feature_list)
        feature_list.map do |feature|
          feature.to_h.slice(:name, :phone, :email, :species, :s3_image_url, :longtitude, :latitude, :distance)
        end
      end
    end
  end
end
