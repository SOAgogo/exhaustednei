# frozen_string_literal: true

require_relative 'test_helper'

describe 'Tests Animal API ' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Shelter information' do
    before do
      # update the DogCat_results every single day when do this tests
      # @project = PetAdoption::Gateway::AnimalAPI.new(RESOURCE_PATH)
      @project = PetAdoption::CurlDownload::FileDownloader.new
      @animal_shelter_initator = PetAdoption::Mapper::AnimalShelterInitiator.new(@project)

      @county_shelter_mapper, @animal_mapper = @animal_shelter_initator.init

      @county_shelter_mapper.create_all_shelter_animal_obj(
        PetAdoption::Mapper::AnimalMapper.shelter_animal_mapping(@animal_mapper.animal_info_list)
      )
      @random_county = RandomCounty::County.random_county(@county_shelter_mapper.shelter_obj_map.keys)

      @shelter_mapper = @county_shelter_mapper.shelter_obj_map[@random_county]
      @county_shelter = @county_shelter_mapper.build_entity('新北市')
    end

    it 'HAPPY: find whether there are too many old animals in one county' do
      _(@county_shelter.county_severity_of_old_animals).must_be_instance_of String
    end

    ## TODO: right number
    it 'HAPPY: shelter should promote some animals to user according to the users preference' do
      feature_condition = { species: '混種犬', animal_age: 'ADULT', color: '黑色',
                            sex: 'F', sterilized: true, vaccinated: false,
                            bodytype: 'MEDIUM' }
      feature_user_want_ratio = [0.2, 0.2, 0.1, 0.3, 0.1, 0.05, 0.05]

      res = @county_shelter.county_shelter_list.map do |_, shelter|
        shelter.promote_to_user(feature_condition, feature_user_want_ratio, 1)
      end

      _(res.size).must_equal @county_shelter.county_shelter_list.size
    end

    it 'HAPPY: shelter should accept donation' do
      money = 1000
      @county_shelter.county_shelter_list.map do |_, shelter|
        shelter.accept_donation(money)
      end
      res = @county_shelter.county_shelter_list.map do |_, shelter|
        shelter.show_the_total_donations
      end
      _(res.all? { |x| x == 1000 }).must_equal true
    end
  end
end
