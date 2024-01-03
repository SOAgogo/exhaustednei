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
        '台灣大學'
      )
      @poster2 = PetAdoption::LossingPets::FinderMapper.new(
        { name: 'user3', user_email: 'onty@gmail.com', phone_number: '08-112312', county: '宜蘭' },
        '礁溪溫泉'
      )
      @poster3 = PetAdoption::LossingPets::FinderMapper.new(
        { name: 'user4', user_email: 'oty@gmail.com', phone_number: '08-1123212', county: '台中' },
        '逢甲夜市'
      )
      @poster4 = PetAdoption::LossingPets::FinderMapper.new(
        { name: 'user5', user_email: 'ayo@gmail.com', phone_number: '08-1123314', county: '台南' },
        '赤崁樓'
      )

      @keeper.upload_image('spec/test_s3_upload_image/Alaskan_malamute.jpg')
      @poster2.upload_image('spec/test_s3_upload_image/labrador.png')
      @poster3.upload_image('spec/test_s3_upload_image/margis3.jpeg')
      @keeper.store_user_info
      @poster2.store_user_info
      @poster3.store_user_info
    end

    it 'should get the image public url from s3' do
      _(@keeper.s3_images_url).must_equal('https://soapicture.s3.ap-northeast-2.amazonaws.com/uploadsspec/test_s3_upload_image/Alaskan_malamute.jpg')
    end

    it 'SAD: should raise error when the image has been upload to s3' do
      _(proc do
        @poster4.upload_image('spec/test_s3_upload_image/margis3.jpeg')
      end).must_raise PetAdoption::LossingPets::KeeperMapper::Errors::DuplicateS3FileName
    end

    it 'should store the keeper info to DB and examine the stored data is correct' do
      keeper_db = @keeper.users.find_user_info_by_image_url(@keeper.s3_images_url)
      _(keeper_db[:name]).must_equal('user2')
      _(keeper_db[:phone_number]).must_equal('08-7488121')
      _(keeper_db[:user_email]).must_equal('ton@gmail.com')
      _(keeper_db[:county]).must_equal('新竹')
    end

    it 'should get the correct number of animals nearby you' do
      keeper_entity = @keeper.build_entity(7000, false)
      _(keeper_entity.how_many_results).must_be_instance_of(Integer)
    end

    it 'should get the distance between you and the animal' do
      keeper_entity = @keeper.build_entity(50_000, false)
      _(keeper_entity.lossing_animals_list.each do |obj|
        _(obj[:distance]).must_be_instance_of(Float)
      end)
    end

    it 'should notify the finder' do
      keeper_entity = @keeper.build_entity(50_000, false)
      _(keeper_entity.notify_finders).must_be_instance_of(Array)
      _(keeper_entity.contact_me).must_be_instance_of(PetAdoption::Values::ContactInfo)
    end

    it 'posters should find the first contact vet' do
      poster = @poster2.build_entity(50_000, 5)
      # _(poster.first_contact_vet).must_be_instance_of(PetAdoption::Values::VetInfo)
      _(poster.first_contact_vet).must_raise PetAdoption::Entity::Finders::Errors::CantFindTheVets
      _(poster.animals_take_care_suggestions).must_be_instance_of(PetAdoption::Values::TakeCareInfo)
      _(poster.contact_me).must_be_instance_of(PetAdoption::Values::ContactInfo)
    end
  end
end
