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
      @keeper = PetAdoption::LossingPets::KeeperMapper.new(
        { hair: 'long', body_type: 'big', kind: 'dog' },
        { name: 'user2', user_email: 'ton@gmail.com', phone_number: '08-7488121', county: '新竹' },
        '台達館'
      )
      @keeper2 = PetAdoption::LossingPets::KeeperMapper.new(
        { hair: 'short', body_type: 'small', kind: 'cat' },
        { name: 'user3', user_email: 'onty@gmail.com', phone_number: '08-112312', county: '花蓮' },
        '清水斷崖'
      )
      @keeper3 = PetAdoption::LossingPets::KeeperMapper.new(
        { hair: 'long', body_type: 'big', kind: 'dog' },
        { name: 'user4', user_email: 'oty@gmail.com', phone_number: '08-1123212', county: '台中' },
        '逢甲夜市'
      )

      @keeper.upload_image('spec/test_s3_upload_image/Alaskan_malamute.jpg')
      @keeper2.upload_image('spec/test_s3_upload_image/labrador.png')

      @keeper.store_user_info
      @keeper2.store_user_info
    end

    it 'should get the image public url from s3' do
      _(@keeper.s3_images_url).must_equal('https://soapicture.s3.ap-northeast-2.amazonaws.com/uploadsspec/test_s3_upload_image/Alaskan_malamute.jpg')
    end

    it 'SAD: should raise error when the image has been upload to s3' do
      _(proc do
        @keeper3.upload_image('spec/test_s3_upload_image/labrador.png')
      end).must_raise PetAdoption::LossingPets::KeeperMapper::Errors::DuplicateS3FileName
    end

    it 'should store the keeper info to DB and examine the stored data is correct' do
      keeper_db = @keeper.users.find_user_info_by_image_url(@keeper.s3_images_url)
      _(keeper_db[:name]).must_equal('user2')
      _(keeper_db[:phone_number]).must_equal('08-7488121')
      _(keeper_db[:user_email]).must_equal('ton@gmail.com')
    end

    it 'should get the correct number of animals nearby you' do
      keeper_entity = @keeper.build_entity(300, false)
      _(keeper_entity.how_many_results).must_be_instance_of(Integer)
    end

    it 'should get the distance between you and the animal' do
      keeper_entity = @keeper2.build_entity(300, false)
      _(keeper_entity.lossing_animals_list.each do |obj|
        _(obj[:distance]).must_be_instance_of(Float)
      end)
    end
  end
end
