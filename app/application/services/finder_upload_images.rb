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
      # step :reify_vets

      private

      def validate_input(input)
        if input.success?
          input = input.to_h.transform_keys(&:to_s)
          # puts 'validate input success'
          Success(input)
        else
          Failure(input.errors.to_h)
        end
      end

      def upload_image(input)
        file_path = input['file']
        # puts file_path
        s3 = PetAdoption::Storage::S3.new
        base_url, object = PetAdoption::Storage::S3.object_url(file_path)
        PetAdoption::Storage::S3.upload_image_to_s3(file_path)
        # puts 'upload image success'
        s3.make_image_public(object)
        input['file'] = "#{base_url}/#{object}"
        # puts 'upload image success'
        Success(input:)
      rescue StandardError => e
        Failure(e.message)
      end

      def find_the_vets(input)
        input[:response] = PetAdoption::Gateway::Api.new(PetAdoption::App.config).recommend_some_vets(input[:input])
        http_presenter = Representer::HttpResponse.new(OpenStruct.new).from_json(input[:response].payload)
        http_presenter.status == 'processing' ? Success(input) : Failure(http_presenter.message)
      rescue StandardError
        Failure('Sorry, in this moment, there is no vet nearby you')
      end

      # def reify_vets(input)
      #   unless input[:response].processing?
      #     Representer::VetRecommeandation.new(OpenStruct.new).from_json(results.payload)
      #       # .then { |vets| Success(vets) }
      #       .then { input[:vets] = _1 }
      #   end
      #   Success(input)
      #   # puts 'vets can be created here'
      # rescue StandardError
      #   Failure('Error in parsing vets')
      # end
    end

    # FinderGetResults
  end
end
