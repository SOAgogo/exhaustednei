# frozen_string_literal: true

# PromoteUserAnimals
module PetAdoption
  module Services
    # class PromoteUserAnimals`
    class PromoteUserAnimals
      include Dry::Transaction

      step :validate_input
      step :get_all_promotions
      step :promote_to_user

      private

      def validate_input(input)
        if input.success?
          Success(input)
        else
          Failure(input.errors.to_h)
        end
      end

      def get_all_promotions(user_input)
        user_input = user_input.to_h.transform_keys(&:to_s)
        res = Gateway::Api.new(PetAdoption::App.config).promote_user_animals(user_input)
        Success(res)
      rescue StandardError
        Failure('Error in getting all promotions')
      end

      def promote_to_user(results)
        animals = Representer::AllAnimalRecommendation.new(OpenStruct.new).from_json(results.payload)
        Success(animals)
      rescue StandardError
        Failure('Error in parsing recommendations')
      end
    end
  end
end
