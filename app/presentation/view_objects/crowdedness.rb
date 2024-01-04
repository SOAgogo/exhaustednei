# frozen_string_literal: true

module PetAdoption
  module Views
    # View for crowdedness
    class ShelterCrowdedness
      def initialize(crowdedness)
        @crowdedness = crowdedness
      end

      def value
        @crowdedness.value!.crowdedness
      end
    end
  end
end
