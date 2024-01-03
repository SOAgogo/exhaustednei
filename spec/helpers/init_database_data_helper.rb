# frozen_string_literal: true

require_relative '../../app/infrastructure/download/curl_download_file'
require_relative '../../app/domain/promote_animals_to_users/mappers/animal_shelter_initiator'
require_relative '../../app/domain/promote_animals_to_users/mappers/animal_mapper'
require_relative '../../app/domain/promote_animals_to_users/mappers/shelter_mapper'
require_relative '../../app/domain/promote_animals_to_users/repositories/for'

module Repository
  module App
    # init_database for initializing database
    class PrepareDatabase
      def self.init_database
        project = PetAdoption::CurlDownload::FileDownloader.new
        animal_shelter_initator = PetAdoption::Mapper::AnimalShelterInitiator.new(project)
        countyshelter_mapper, animal_mapper = animal_shelter_initator.init

        countyshelter_mapper.create_all_shelter_animal_obj(
          PetAdoption::Mapper::AnimalMapper.shelter_animal_mapping(animal_mapper.animal_info_list)
        )

        PrepareDatabase.store_shelter_info_to_db(countyshelter_mapper, project)
      end

      def self.store_shelter_info_to_db(countyshelter_mapper, project)
        project.request_body.each do |shelter_obj|
          shelter_list = countyshelter_mapper.get_shelter_obj_list(shelter_obj['shelter_name'][0..2])

          shelter_list.map do |_, shelter|
            PetAdoption::Repository::For.entity(shelter).db_find_or_create(shelter)
          end
        end
      end
    end
  end
end
