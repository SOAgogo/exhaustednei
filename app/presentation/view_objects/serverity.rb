# frozen_string_literal: true

module PetAdoption
  module Views
    # View for serverity
    class Serverity
      def initialize(metrics)
        @metrics = metrics
        @value = @metrics.value!
      end

      def old_animal_num
        @value.old_animals_number
      end

      def serverity
        @value.severity
      end
    end
  end
end
