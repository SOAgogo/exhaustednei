# frozen_string_literal: true

require_relative 'list_request'
require 'http'

module PetAdoption
  module Gateway
    # Infrastructure to call CodePraise API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def shelter_crowdedness(shelter_name)
        @request.get_shelter_crowdedness(shelter_name)
      end

      def number_of_old_animals(shelter_name)
        @request.get_number_of_old_animals(shelter_name)
      end

      def get_all_animals_in_shelter(animal_kind, shelter_name)
        @request.get_all_animals_in_shelter(animal_kind, shelter_name)
      end

      # post request
      def recommend_some_vets(user_preference)
        @request.recommend_some_vets(user_preference)
      end

      def count_animal_score(user_preference)
        @request.count_animal_score(user_preference)
      end

      def promote_user_animals(user_preference)
        @request.promote_user_animals(user_preference)
      end

      def contact_finders(keeper_info)
        @request.contact_finders(keeper_info)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{config.API_HOST}/api/v1"
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def get_shelter_crowdedness(shelter_name)
          call_api('get', ['shelters', 'crowdedness', shelter_name])
        end

        def get_number_of_old_animals(shelter_name)
          call_api('get', ['shelters', 'oldanimals', shelter_name])
        end

        def get_all_animals_in_shelter(animal_kind, shelter_name)
          call_api('get', ['shelters', animal_kind, shelter_name])
        end

        def recommend_some_vets(user_preference)
          puts user_preference
          call_api('post', %w[finder vets], user_preference)
        end

        def count_animal_score(user_preference)
          call_api('post', %w[user count-animal-score], user_preference)
        end

        def contact_finders(keeper_info)
          call_api('post', %w[keeper contact], keeper_info)
        end

        def promote_user_animals(user_preference)
          call_api('post', %w[promote-user-animals], user_preference)
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
            .then { |str| str ? "?#{str}" : '' }
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          puts api_path, url
          HTTP.headers('Accept' => 'application/json').send(method, url)
            .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS_CODES = (200..299)

        def success?
          code.between?(SUCCESS_CODES.first, SUCCESS_CODES.last)
        end

        def message
          payload['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
