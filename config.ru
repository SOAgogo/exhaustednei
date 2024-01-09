# frozen_string_literal: true

require_relative 'require_app'
require 'faye'

use Faye::RackAdapter, mount: '/faye', timeout: 25

require_app

run PetAdoption::App.freeze.app
