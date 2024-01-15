# frozen_string_literal: true

require 'dry/transaction'

module PetAdoption
  module Services
    # Service to get the results from the finder
    class FinderGetResults
      include Dry::Transaction
      step :check_data_prepared_in_redis

      private

      FAILMSG = 'data not yet prepared in redis'

      def check_data_prepared_in_redis
        take_care_info, vet_check = cache_check_helper

        if take_care_info.nil? || vet_check.nil?
          return Failure(Response::ApiResult.new(status: :processing, message: FAILMSG))
        end

        rsp = response(take_care_info, vet_check)

        delete_elements_in_redis # delete elements in redis
        vets = Representer::VetRecommeandation.new(OpenStruct.new).from_json(rsp)
        Success(vets)
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: 'system error'))
      end

      # helper function for cache data check
      def cache_check_helper
        cache = PetAdoption::Cache::RedisCache.new(App.config)
        # polling from redis
        sleep(1) until cache.get('take_care_info') && cache.get('vets')
        [cache.get('take_care_info'), cache.get('vets')]
      end

      def delete_elements_in_redis
        cache = PetAdoption::Cache::RedisCache.new(App.config)
        cache.del('take_care_info')
        cache.del('vets')
      end

      def response(take_care_info, vet_check)
        vet_check = JSON.parse(vet_check)
        take_care_info = JSON.parse(take_care_info)

        # Create a hash with the desired structure
        merged_data = {
          'clinics' => vet_check.map do |clinic|
            clinic.merge('open_time' => clinic['open_time'].to_s) # Convert boolean to string
          end,
          'take_care_info' => take_care_info
        }

        # Convert the hash back to JSON
        JSON.generate(merged_data)
      end
    end
  end
end
