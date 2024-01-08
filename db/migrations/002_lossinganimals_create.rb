# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:loss_animals) do
      primary_key :id

      String :name
      # String :phone_number, null: false, unique: true
      String :phone, null: false
      # String :user_email, unique: true
      String :email
      String :county
      String :species, null: false
      String :s3_image_url, null: false, unique: true
      String :address
      Boolean :keeper_or_finder, null: false
      Float :longtitude, null: false
      Float :latitude, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
