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
      @project = PetAdoption::Gateway::AnimalAPI.new(RESOURCE_PATH)
      @animal_shelter_initator = PetAdoption::Mapper::AnimalShelterInitiator.new(@project)

      @county_shelter_mapper, @animal_mapper = @animal_shelter_initator.init

      @county_shelter_mapper.create_all_shelter_animal_obj(
        PetAdoption::Mapper::AnimalMapper.shelter_animal_mapping(@animal_mapper.animal_info_list)
      )
      @random_county = RandomCounty::County.random_county(@county_shelter_mapper.shelter_obj_map.keys)

      @shelter = @county_shelter_mapper.shelter_obj_map[@random_county]
    end

    ans = File.read('spec/fixtures/DogCat_results.json')
    file = JSON.parse(ans)[0..19]
    random = rand(0..19)
    shelter_name_ans = file.map { |n| n['shelter_name'] }.uniq.size

    rand_shelter_name = file[random]['shelter_name']
    num_aml_shelter_ans = file.select { |n| n['shelter_name'] == rand_shelter_name }.size

    it 'HAPPY: should connect to api successfully' do
      _(@project.request_body[0].keys).must_equal CORRECT[0].keys
    end
    it 'HAPPY: should provide the same fields as same as the ones in CORRECT DATA' do
      _(@county_shelter_mapper.shelter_size).must_equal shelter_name_ans
    end

    ## TODO: right number
    it 'HAPPY: shelter should provide the correct animal numbers' do
      aml_number = @shelter.shelter_stats.animal_num
      _(aml_number).must_equal num_aml_shelter_ans
    end

    it 'SAD: should raise exception on incorrect url' do
      path = "#{RESOURCE_PATH}/error_here"
      project = PetAdoption::Gateway::AnimalAPI.new(path)
      project.connection
      _(
        project.request_body.to_s
      ).must_equal ''
    end

    it 'HAPPY: should provide correct animal numbers in each shelter' do
      aml_number = @shelter.shelter_stats.animal_num
      _(aml_number).must_equal num_aml_shelter_ans
    end
  end
end
