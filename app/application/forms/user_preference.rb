# frozen_string_literal: true

require 'dry-validation'

module PetAdoption
  module Forms
    # Form validation for Github project URL
    class UserPreference < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        required(:email).filled(:string)
        required(:phone).filled(:string)
        required(:address).filled(:string)
        required(:age).filled(:string)
        required(:sex).filled(:string)
        required(:sterilized).filled(:string)
        required(:vaccinated).filled(:string)
        required(:bodytype).filled(:string)
        required(:species).filled(:string)
        required(:color).filled(:string)
        required(:animal_id).filled(:string)
      end

      EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      PHONE_REGEX_TAIWAN_MOBILE = /\A09\d{8}\z/ # Adjust this regex based on your phone number validation requirements

      rule(:email) do
        key.failure('must be a valid email address') unless value.match?(EMAIL_REGEX)
      end
      rule(:phone) do
        key.failure('must be a valid Taiwan mobile phone number') unless value.match?(PHONE_REGEX_TAIWAN_MOBILE)
      end

      rule(:address) do
        key.failure('must contain 縣(市)') unless value.match?(/[縣市]/)
        key.failure('must contain 鄉(鎮)(區)') unless value.match?(/[區鄉鎮]/)
        key.failure('must contain 路(街)') unless value.include?('路') || value.include?('街')
        key.failure('must contain 號') unless value.include?('號')
      end

      rule(:age) do
        key.failure('must be CHILD or ADULT') unless value == 'CHILD' || value == 'ADULT'
      end

      rule(:sterilized) do
        key.failure('must be yes or no') unless value == 'yes' || value == 'no'
      end

      rule(:vaccinated) do
        key.failure('must be yes or no') unless value == 'yes' || value == 'no'
      end
      rule(:bodytype) do
        key.failure('must be SMALL or MEDIUM or LARGE') unless value == 'SMALL' || value == 'MEDIUM' || value == 'LARGE'
      end

      rule(:sex) do
        key.failure('must be GIRL or BOY') unless value == 'M' || value == 'F'
      end

      rule(:color) do
        key.failure('must be Chinese') unless value =~ /\p{Han}/
      end
    end

    # Form validation for Github project URL
    class HumanReadAble
      def self.error(hash)
        string = ''
        hash.map do |key, list_value|
          string += "#{key} \t"
          string = HumanReadAble.error_message(list_value, string)
          string += ",\t"
        end
      end

      def self.error_message(list_value, string)
        list_value.map do |value|
          string += " #{value}"
        end
        string
      end
    end
  end
end
