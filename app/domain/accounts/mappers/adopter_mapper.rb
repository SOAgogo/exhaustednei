# frozen_string_literal: true

module PetAdoption
  module Accounts
    # class Info::ShelterMapper`
    class AdopterMapper
      def self.find
        DataMapper.build_adopter_info_entity
      end
    end

    # Datamapper for adopter_info
    class DataMapper
      def self.build_adopter_info_entity
        PetAdoption::Entity::Adopters.new
      end
    end
  end
end
