# frozen_string_literal: true

require 'sequel'

module Database
  module ProjectOrm
    # Object-Relational Mapper for Shelters
    class ShelterOrm < Sequel::Model(:shelters)
      one_to_many :animal_relations,
                  class: :'Database::ProjectOrm::AnimalOrm',
                  key: :shelter_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(member_info)
        first(username: member_info[:username]) || create(member_info)
      end
    end
  end
end
