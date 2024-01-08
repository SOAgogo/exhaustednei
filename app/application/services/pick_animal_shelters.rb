# frozen_string_literal: true

module PetAdoption
  module Services
    # class PickAnimalInfo`

    # class SelectAnimal`
    class SelectAnimal
      include Dry::Transaction

      step :validate_input
      step :select_animal
      step :reify_animal

      private

      def validate_input(input)
        if input.success?
          Success(input)
        else
          Failure(input.errors.to_h)
        end
      end

      def select_animal(input)
        animal_obj_list = Gateway::Api.new(PetAdoption::App.config)
          .get_all_animals_in_shelter(input[:animal_kind], input[:shelter_name])

        Success(animal_obj_list)
      rescue StandardError
        Failure('cant find any animal in this shelter')
      end

      def reify_animal(results)
        animals = Representer::ShelterAnimals.new(OpenStruct.new).from_json(results.payload)
        Success(animals)
      rescue StandardError
        Failure('Error in parsing animals')
      end
    end

    # class PickAnimalByOriginID`
    class PickAnimalByOriginID
      include Dry::Transaction

      step :validate_input
      step :modify_input
      step :create_similarity
      step :reify_similarity

      private

      def validate_input(input)
        if input.success?
          Success(input)
        else
          Failure(input.errors.to_h)
        end
      end

      def modify_input(input)
        input = input.to_h.transform_keys(&:to_s).except('name', 'email', 'phone', 'address')
        Success(input:)
      end

      def create_similarity(input)
        animal_similarity = Gateway::Api.new(PetAdoption::App.config)
          .count_animal_score(input[:input])

        Success(animal_similarity)
      rescue StandardError
        Failure('Error in counting scores')
      end

      def reify_similarity(results)
        scores = Representer::AnimalScore.new(OpenStruct.new).from_json(results.payload)
        Success(scores)
      rescue StandardError
        Failure('Error in parsing scores')
      end
    end

    # class ShelterCapacityCounter`
    class ShelterCapacityCounter
      include Dry::Transaction

      step :validate_input
      step :shelter_capacity
      step :reify_crowdedness

      private

      def validate_input(input)
        if input.success?
          Success(input)
        else
          Failure(input.errors.to_h)
        end
      end

      def shelter_capacity(input)
        shelter_obj = Gateway::Api.new(PetAdoption::App.config)
          .shelter_crowdedness(input[:shelter_name])

        Success(shelter_obj)
      rescue StandardError => e
        Failure(e.message)
      end

      def reify_crowdedness(results)
        crowdedness = Representer::ShelterCrowdedness.new(OpenStruct.new).from_json(results.payload)
        Success(crowdedness)
      rescue StandardError
        Failure('Error in parsing metrics')
      end
    end

    # class NumberOfOldAnimals`
    class NumberOfOldAnimals
      include Dry::Transaction

      step :validate_input
      step :number_of_old_animals
      step :reify_old_animals

      private

      def validate_input(input)
        if input.success?
          Success(input)
        else
          Failure(input.errors.to_h)
        end
      end

      def number_of_old_animals(input)
        old_animals = Gateway::Api.new(PetAdoption::App.config)
          .number_of_old_animals(input[:shelter_name])

        Success(old_animals)
      rescue StandardError
        Failure('Error in parsing metrics')
      end

      def reify_old_animals(results)
        old_animals = Representer::ShelterTooOldAnimals.new(OpenStruct.new).from_json(results.payload)
        Success(old_animals)
      rescue StandardError
        Failure('Error in parsing metrics')
      end
    end
  end
end
