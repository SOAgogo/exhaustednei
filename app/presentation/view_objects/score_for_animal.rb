# frozen_string_literal: true

module PetAdoption
  module Views
    # View for crowdedness
    class ScoreForAnimal
      def initialize(score)
        @score = score
      end

      def value
        { scores: @score.value!.scores }
      end
    end
  end
end
