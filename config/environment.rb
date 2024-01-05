# frozen_string_literal: true

require 'figaro'
require 'roda'
require 'logger'
require 'rack/session'
require 'sequel'

module PetAdoption
  # Configuration for the App
  class App < Roda
    plugin :environments
    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment:,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      # for testing and development, use sqlite
      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
      end

      configure :test do
        ENV['testing'] = 'true'
        ENV['TESTING_FILE'] = config.TESTING_FILE.to_s
      end

      use Rack::Session::Cookie, {
        secret: config.SESSION_SECRET,
        expire_after: 60
      }
      # Database Setup
      # @db = Sequel.connect(ENV.fetch('DATABASE_URL'))
      # def self.db = @db

      # Logger Setup
      # @logger = Logger.new($stderr)
      @logger = Logger.new($stdout)
      def self.logger = @logger # rubocop:disable Style/TrivialAccessors

      configure :development, :test, :app_test do
        require 'pry'; # for breakpoints
      end
    end
  end
end
