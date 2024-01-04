# frozen_string_literal: true

module PetAdoption
  module Views
    # View for a single contributor
    class AnimalInShelter
      def initialize(animal_obj_list)
        @animal_objs = animal_obj_list
      end

      def value
        @animal_objs.value!
      end

      def transform
        value.animal_obj_list.map do |animal_obj|
          animal_obj.animal.to_h.except(:links)
        end
      end
    end
  end
end
