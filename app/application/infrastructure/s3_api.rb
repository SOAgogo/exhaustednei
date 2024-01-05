# frozen_string_literal: true

require 'open3'
require 'aws-sdk-s3'
require 'yaml'

module PetAdoption
  module Storage
    # class Info::Project`
    BASE_URL = 'https://soapicture.s3.ap-northeast-2.amazonaws.com'
    BUCKET_NAME = ENV.fetch('S3_Bucket_Name', nil)
    REGION = ENV.fetch('S3_Region', nil)

    # class S3
    class S3
      # @@secrets = YAML.load_file('config/secrets.yml')
      def self.s3_init
        access_key_id = ENV.fetch('S3_Access_Key', nil)
        secret_key_id = ENV.fetch('S3_Secret_Key', nil)

        # Access the keys
        Aws.config.update(
          region: REGION,
          credentials: Aws::Credentials.new(access_key_id, secret_key_id)
        )
      end

      def initialize
        S3.s3_init
        @s3 = Aws::S3::Client.new(region: REGION,
                                  credentials: Aws::Credentials.new(
                                    ENV.fetch('S3_Access_Key', nil), ENV.fetch('S3_Secret_Key', nil)
                                  ))
      end

      def make_all_images_public
        response = view_image_from_s3
        response.contents.each do |object|
          # Set the ACL of the object to public-read
          make_image_public(object.key)
        end
      end

      def make_image_public(object_key)
        @s3.put_object_acl(
          bucket: BUCKET_NAME,
          key: object_key,
          acl: 'public-read'
        )
      end

      def view_image_from_s3
        @s3.list_objects_v2(bucket: BUCKET_NAME, prefix: 'uploadsspec/test_s3_upload_image/')
      end

      # examine the s3 object has been uploaded
      def self.object_url(uploaded_file)
        [BASE_URL, "uploads#{uploaded_file}"]
      end

      def self.upload_image_to_s3(uploaded_file)
        s3_init
        _, object_key = object_url(uploaded_file)
        aws_s3 = Aws::S3::Resource.new
        aws_s3.bucket(BUCKET_NAME).object(object_key).upload_file(uploaded_file,
                                                                  content_type: 'image/png;image/jpg;image/jpeg')
      rescue StandardError => e
        raise e.message
      end
    end
  end
end
