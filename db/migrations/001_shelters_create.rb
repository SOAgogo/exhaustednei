# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:shelters) do
      primary_key :id

      Integer :origin_id, unique: true, null: false
      String :name, null: false
      String :address, null: false
      String :phone_number
      Integer :cat_num, null: false
      Integer :dog_num, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
