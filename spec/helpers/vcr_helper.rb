# frozen_string_literal: true

require 'vcr'
require 'webmock'
require_relative 'spec_helper'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'animals-record'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
    end
  end

  def self.configure_vcr_for_website # rubocop:disable Metrics/MethodLength
    VCR.configure do |config|
      config.filter_sensitive_data('<GPT_TOKEN>') { GPT_TOKEN }
      config.filter_sensitive_data('<GPT_TOKEN_ESC>') { CGI.escape(GPT_TOKEN) }
      config.filter_sensitive_data('<MAP_TOKEN>') { MAP_TOKEN }
      config.filter_sensitive_data('<MAP_TOKEN_ESC>') { CGI.escape(MAP_TOKEN) }
    end
    VCR.insert_cassette(
      CASSETTE_FILE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
