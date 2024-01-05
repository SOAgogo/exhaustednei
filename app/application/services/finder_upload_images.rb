# frozen_string_literal: true

require 'dry/transaction'

module PetAdoption
  module Services
    # class ImageRecognition`
    class FinderUploadImages
      include Dry::Transaction
      step :validate_input
      step :upload_image
      step :find_the_vets
      step :reify_vets

      private

      def validate_input(input)
        if input.success?
          input = input.to_h.transform_keys(&:to_s)
          Success(input)
        else
          Failure(input.errors.to_h)
        end
      end

      def upload_image(input)
        file_path = input['file']
        puts 'file path exists'
        s3 = PetAdoption::Storage::S3.new
        puts 's3 object created'
        base_url, object = PetAdoption::Storage::S3.object_url(file_path)
        puts 'set base url and object'
        PetAdoption::Storage::S3.upload_image_to_s3(file_path)
        puts 'upload image to s3'
        s3.make_image_public(object)
        puts 'make image public'
        input['file'] = "#{base_url}/#{object}"
        puts "#{base_url}/#{object}"

        Success(input:)
      rescue StandardError => e
        Failure(e.message)
      end

      def find_the_vets(input)
        puts 'start to find vets'
        res = PetAdoption::Gateway::Api.new(PetAdoption::App.config).recommend_some_vets(input[:input])
        puts 'res success!!!!!'
        Success(res)
      rescue StandardError
        Failure('Sorry, in this moment, there is no vet nearby you')
      end

      def reify_vets(results)
        vets = Representer::VetRecommeandation.new(OpenStruct.new).from_json(results.payload)
        puts 'vets success!!!!!'
        Success(vets)
      rescue StandardError
        Failure('Error in parsing vets')
      end
    end
  end
end
