# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../../../../app/application/controllers/app'
require_relative '../../../helpers/database_helper'
require 'json'

BASE_URL = PetAdoption::Storage::BASE_URL
BUCKET_NAME = PetAdoption::Storage::BUCKET_NAME
describe 'Check how many surronding animals' do
  # run testing=true bundle exec rake run first before running this test
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
    DatabaseHelper.wipe_lossing_database
  end

  after do
    VCR.eject_cassette
  end

  describe 'HAPPY: should get the correct number of animals nearby you' do
    # fine
    before do
      @poster = PetAdoption::LossingPets::FinderMapper.new(
        { name: 'tony', user_email: 'y11212@gmail.com', phone_number: '08-77121364', county: '新竹' },
        '台積館'
      )
      @poster2 = PetAdoption::LossingPets::FinderMapper.new(
        { name: 'user3', user_email: 'onty@gmail.com', phone_number: '08-112312', county: '宜蘭' },
        '礁溪溫泉'
      )
      @poster3 = PetAdoption::LossingPets::FinderMapper.new(
        { name: 'user4', user_email: 'oty@gmail.com', phone_number: '08-1123212', county: '台中' },
        '逢甲夜市'
      )
      @poster.upload_image('spec/test_s3_upload_image/schooldog.jpg')
      @poster.store_user_info
      @poster2.upload_image('spec/test_s3_upload_image/labrador.png')
      @poster2.store_user_info
    end

    it 'should give finders some vets recommedations' do
      _(@poster.s3_images_url).must_equal('https://soapicture.s3.ap-northeast-2.amazonaws.com/uploadsspec/test_s3_upload_image/schooldog.jpg')
    end

    it 'SAD: should raise error when the image has been upload to s3' do
      _(proc do
        @poster3.upload_image('spec/test_s3_upload_image/schooldog.jpg')
      end).must_raise PetAdoption::LossingPets::FinderMapper::Errors::DuplicateS3FileName
    end

    it 'should store the finders info to DB and examine the stored data is correct' do
      poster_db = @poster.users.find_user_info_by_image_url(@poster.s3_images_url)
      _(poster_db[:name]).must_equal('tony')
      _(poster_db[:phone_number]).must_equal('08-77121364')
      _(poster_db[:user_email]).must_equal('y11212@gmail.com')
      _(poster_db[:county]).must_equal('新竹')
    end

    it 'should get the take care suggestoions from gpt' do
      poster_entity = @poster.build_entity(7000, 10) # meter, top_ratings
      _(poster_entity.first_contact_vet.size).instance_of?(Integer)
      _(poster_entity.animals_take_care_suggestions).must_be_instance_of(String)
    end

    it 'SAD: raise error when search distance is too short' do
      _(proc do
        @poster.build_entity(2, 10)
      end).must_raise PetAdoption::GeoLocation::GoogleMapApi::Errors::SearchDistanceTooShort # meter, top_ratings
    end
  end
end
