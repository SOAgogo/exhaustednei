# frozen_string_literal: true

require 'rake/testtask'
require_relative 'require_app'

task :default do
  puts `rake -T`
end

desc 'update daily government data'
task :update do
  sh 'ruby app/data_init.rb'
end

namespace :spec do
  desc 'Run unit and integration tests'
  Rake::TestTask.new(:default) do |t|
    t.pattern = 'spec/tests/{integration}/{layers}/*_spec.rb'
    # t.pattern = 'spec/tests/{unit}/*_spec.rb'
    # t.pattern = 'spec/tests/{integration,unit}/**/*_spec.rb'
    # t.pattern = 'spec/tests/integration/layers/gateway_animal_spec.rb'
    t.warning = false
  end

  desc 'Run unit, integration, and acceptance tests'
  Rake::TestTask.new(:all) do |t|
    t.pattern = 'spec/tests/**/*_spec.rb'
    t.warning = false
  end
end

namespace :another do
  desc 'Run unit and integration tests'
  Rake::TestTask.new(:domain) do |t|
    t.pattern = 'spec/tests/{integration}/{domain}/*_spec.rb'
    # t.pattern = 'spec/tests/{unit}/*_spec.rb'
    # t.pattern = 'spec/tests/{integration,unit}/**/*_spec.rb'
    # t.pattern = 'spec/tests/integration/layers/gateway_animal_spec.rb'
    t.warning = false
  end
end

desc 'Keep rerunning tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'Run the application (default: development mode)'
task run: ['run:dev']

namespace :run do
  desc 'Run the application in development mode'
  task :dev do
    sh "rerun -c --ignore 'coverage/*'  -- bundle exec puma"
  end

  desc 'Run the application in test mode'
  task :test do
    sh "rerun -c --ignore 'coverage/*' -- bundle exec puma -p 9000"
  end
end

desc 'Keep rerunning web app upon changes'
task :rerun do
  sh "rerun -c --ignore 'coverage/*' -- bundle exec puma"
end

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all'
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app = PetAdoption::App
  end

  # daily update database
  desc 'Run data initialization for database'
  task :datainit => :config do
    require_relative 'spec/helpers/init_database_data_helper'
    require_app('infrastructure')
    require_app('models')
    puts 'puts all the data in the database'
    # DatabaseHelper.wipe_database
    Repository::App::PrepareDatabase.init_database
  end

  desc 'Run migrations'
  task :migrate => :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.db, 'db/migrations')
  end

  desc 'Wipe records from all tables'
  task :wipe => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    require_app('infrastructure')
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task :drop => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(PetAdoption::App.config.DB_FILENAME)
    puts "Deleted #{PetAdoption::App.config.DB_FILENAME}"
  end
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  only_app = 'config/ app/'

  desc 'run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop'
  end

  desc 'code smell detector'
  task :reek do
    sh 'reek'
  end

  desc 'complexiy analysis'
  task :flog do
    sh "flog -m #{only_app}"
  end
end
