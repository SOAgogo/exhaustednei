# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    PetAdoption::App.db.run('PRAGMA foreign_keys = OFF')
    Database::ProjectOrm::AnimalOrm.map(&:destroy)
    Database::ProjectOrm::ShelterOrm.map(&:destroy)
    Database::ProjectOrm::LossingPetsOrm.map(&:destroy)
    PetAdoption::App.db.run('PRAGMA foreign_keys = ON')
  end

  def self.wipe_lossing_database
    PetAdoption::App.db.run('PRAGMA foreign_keys = OFF')
    Database::ProjectOrm::LossingPetsOrm.map(&:destroy)
    PetAdoption::App.db.run('PRAGMA foreign_keys = ON')
  end
end
