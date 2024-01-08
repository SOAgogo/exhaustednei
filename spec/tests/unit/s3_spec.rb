# frozen_string_literal: true

# test the data coming from gateway api are the same as the data in the database
require_relative '../../helpers/vcr_helper'
require 'uri'
require 'json'

describe 'Test S3 API' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_website
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Unit test of S3 upload image' do
    before do
      @aws_s3 = PetAdoption::Storage::S3.new
    end
    it 'HAPPY: should upload image to S3' do
      base_url, object_key = PetAdoption::Storage::S3.upload_image_to_s3('spec/test_s3_upload_image/margis3.jpeg')
      @aws_s3.make_image_public(object_key)
      _("#{base_url}/#{object_key}").must_equal('https://soapicture.s3.ap-northeast-2.amazonaws.com/uploadsspec/test_s3_upload_image/margis3.jpeg')
    end
    it 'HAPPY: should lists all images on S3' do
      picture_obj_list = @aws_s3.view_image_from_s3[1]
      _(picture_obj_list).must_be_instance_of(Aws::Xml::DefaultList)
    end
  end
end
