# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# CONFIGURATION
gem 'figaro', '~> 1.2'
gem 'pry'
gem 'rake', '~> 13.0'
gem 'libxml-ruby', '~> 3.1'

# PRESENTATION LAYER
gem 'slim', '~> 5.0'

# APPLICATION LAYER
# Web application related
gem 'activerecord', '~> 5.0', '>= 5.0.0.1'
gem 'aws-sdk-s3', '~> 1.141'
gem 'execjs'
gem 'puma', '~> 6.0'
gem 'rack-session', '~> 0.3'
gem 'roda', '~> 3.0'
gem 'roar', '~> 1.0.0'

# Caching
gem 'rack-cache', '~> 1.13'
gem 'redis', '~> 4.8'
gem 'redis-rack-cache', '~> 2.2'

# Controllers and services
gem 'dry-monads', '~> 1.4'
gem 'dry-transaction', '~> 0.13'
gem 'dry-validation', '~> 1.7'

# DOMAIN LAYER
# Validation
gem 'dry-struct', '~> 1.0'
gem 'dry-types', '~> 1.0'

# INFRASTRUCTURE LAYER
# Networking
gem 'geocoder', '~> 1.3', '>= 1.3.7'
gem 'google-maps', '~> 3.0.7'
gem 'http', '~> 5.0'

gem 'open-uri', '~> 0.1'

# Database
gem 'hirb'
# gem 'hirb-unicode' # incompatible with new rubocop
gem 'sequel', '~> 5.0'

group :development, :test do
  gem 'sqlite3', '~> 1.0'
end

group :production do
  gem 'pg', '~> 1.2'
end

# TESTING
group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-rg', '~> 5.0'
  gem 'simplecov', '~> 0.0'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.0'

  gem 'headless', '~> 2.3'
  gem 'page-object', '~> 2.3'
  gem 'watir', '~> 7.0'
  # gem 'webdrivers', '~> 5.0'
  gem 'selenium-webdriver', '~> 4.11'
end

# Development
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rerun', '~> 0.0'
  gem 'rubocop', '~> 1.0'
end
