# frozen_string_literal: true

# Purpose: View object for a vets
module PetAdoption
  module Views
    # View for a vets
    class Clinic
      def initialize(result)
        @clinics = result.value!.clinics
      end

      def clinics # rubocop:disable Metrics/MethodLength
        @clinics.map do |clinic|
          {
            name: clinic.name,
            address: clinic.address,
            open_time: clinic.open_time,
            rating: clinic.rating,
            total_ratings: clinic.total_ratings,
            which_road: clinic.which_road,
            latitude: clinic.latitude,
            longitude: clinic.longitude
          }
        end
      end
    end

    # View for an instruction
    class TakeCareInfo
      attr_reader :instruction

      def initialize(result)
        @instruction = result.value!.take_care_info
      end
    end
  end
end
