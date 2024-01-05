# frozen_string_literal: true

require 'dry/transaction'

module PetAdoption
  module Services
    # class ImageRecognition`
    class KeeperUploadImages
      include Dry::Transaction
      step :validate_input
      step :upload_image
      step :create_keeper_info
      step :reify_keeper

      private

      def validate_input(input)
        if input.success?
          Success(input.to_h.transform_keys(&:to_s))
        else
          Failure(input.errors.to_h)
        end
      end

      def upload_image(input)
        file_path = input['file']
        s3 = PetAdoption::Storage::S3.new
        base_url, object = PetAdoption::Storage::S3.object_url(file_path)

        return Failure('S3 cant upload your image') unless PetAdoption::Storage::S3.upload_image_to_s3(file_path)

        s3.make_image_public(object)
        input['file'] = "#{base_url}/#{object}"

        Success(input)
      rescue StandardError => e
        Failure(e.message)
      end

      def create_keeper_info(input)
        keeper = Gateway::Api.new(PetAdoption::App.config).contact_finders(input)

        Success(keeper)
      rescue StandardError
        Failure('Sorry, in this moment, there is no lost animal nearby you')
      end

      def reify_keeper(results)
        keeper = Representer::PotentialFinderRepresenter.new(OpenStruct.new).from_json(results.payload)
        Success(keeper)
      rescue StandardError
        Failure('Error in parsing keeper')
      end
    end
  end
end
