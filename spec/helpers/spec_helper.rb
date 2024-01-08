# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start

require 'json'
require 'minitest/autorun'
require 'minitest/unit' # minitest Github issue #17 requires
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../../require_app'
require_app

GPT_TOKEN = PetAdoption::App.config.GPT_TOKEN
MAP_TOKEN = PetAdoption::App.config.MAP_TOKEN
S3_ACCESS_KEY_ID = PetAdoption::App.config.S3_ACCESS_KEY_ID
S3_SECRET_ACCESS_KEY = PetAdoption::App.config.S3_SECRET_ACCESS_KEY
RESOURCE_PATH = 'https://data.moa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL'
CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'animals-record'
