# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'pry'
require 'json'
require 'yaml'
# verify your identification

module Info
  class Cat
    def initialize(data)
      @data = data
    end

    def animal_id
      @data['animal_id'].to_i
    end

    def animal_place
      @data['animal_place']
    end

    def animal_kind
      @data['animal_kind']
    end

    def animal_variate
      @data['animal_Variety']
    end

    def animal_sex
      @data['animal_sex']
    end

    def animal_sterilization
      @data['animal_sterilization']
    end

    def animal_bacterin
      @data['animal_bacterin']
    end

    def animal_bodytype
      @data['animal_bodytype']
    end

    def album_file
      @data['album_file']
    end

    def animal_opendate
      @data['animal_opendate']
    end
  end

  class Dog
    def initialize(data)
      @data = data
    end

    def animal_id
      @data['animal_id'].to_i
    end

    def animal_place
      @data['animal_place']
    end

    def animal_kind
      @data['animal_kind']
    end

    def animal_variate
      @data['animal_Variety']
    end

    def animal_sex
      @data['animal_sex']
    end

    def animal_sterilization
      @data['animal_sterilization']
    end

    def animal_bacterin
      @data['animal_bacterin']
    end

    def animal_bodytype
      @data['animal_bodytype']
    end

    def album_file
      @data['album_file']
    end

    def animal_opendate
      @data['animal_opendate']
    end
  end
end
