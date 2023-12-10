# frozen_string_literal: true

# verify your identification
require 'dry-types'
require 'dry-struct'
require_relative 'shelters'
require_relative '../lib/similarity_calculator'
require_relative '../values/animal_features'

module PetAdoption
  module Entity
    # class Info::Animal`
    class Animal
      def initialize(feature)
        @feature = Value::AnimalInfo.new(feature)
      end

      def feature
        { 'animal_age' => @feature.age,
          'color' => @feature.color,
          'sex' => @feature.sex,
          'sterilized' => @feature.sterilized,
          'vaccinated' => @feature.vaccinated,
          'bodytype' => @feature.bodytype }
      end
    end

    # class Info::Cat`
    class Cat < Animal
      include PetAdoption::Mixins::SimilarityCalculator

      def similarity_checking(feature_condition, feature_user_want_ratio, top = 1)
        similarity(feature_condition, feature_user_want_ratio, feature, top)
      end
    end

    # class Info::Dog`
    class Dog < Animal
      include PetAdoption::Mixins::SimilarityCalculator

      def similarity_checking(feature_condition, feature_user_want_ratio, top = 1)
        # return a float number
        similarity(feature_condition, feature_user_want_ratio, feature, top)
      end

      def advanced_similarity_checking(feature_condition, feature_user_want_ratio, top = 1)
        # return a float number
        similarity(feature_condition, feature_user_want_ratio, feature, top)
      end
    end
  end
end
