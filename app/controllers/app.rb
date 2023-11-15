# frozen_string_literal: true

require 'roda'
require 'slim'
require 'json'
require 'uri'
require 'pry'
require 'securerandom'
require 'fileutils'
require 'open3'


module PetAdoption
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets/css'
    plugin :common_logger, $stderr
    plugin :halt
    plugin :json


    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'

      # GET /
      routing.root do
        animal_pic = Repository::Info::Animals.web_page_cover
        view 'home', locals: { image_url: animal_pic }
      end

      routing.on 'animal' do
        routing.is do
          # POST /project/
          routing.post do
            animal_kind = routing.params['animal_kind'].downcase
            shelter_name = routing.params['shelter_name']
            sn_ch = URI.decode_www_form_component(shelter_name)

            routing.redirect "animal/#{animal_kind}/#{sn_ch}"
          end
        end

        routing.on String, String do |animal_kind, shelter_name|
          # GET /project/owner/project
          sn_ch = URI.decode_www_form_component(shelter_name)
          ak_ch = animal_kind == 'dog' ? '狗' : '貓'
          shelter_name = URI.decode_www_form_component(shelter_name)
          animal_kind = URI.decode_www_form_component(ak_ch)
          # animal_obj_hash = Repository::Info::Animals.select_animal_by_shelter_name('狗', '高雄市壽山動物保護教育園區')
          animal_obj_hash = Repository::Info::Animals.select_animal_by_shelter_name(animal_kind, shelter_name)

          # include PetAdoption::Decoder
          animal_obj_hash.each do |key, obj|
            obj.to_decode_hash.merge(
              animal_kind: URI.decode_www_form_component(obj.animal_kind),
              animal_variate: URI.decode_www_form_component(obj.animal_variate),
              animal_place: URI.decode_www_form_component(obj.animal_place),
              animal_found_place: URI.decode_www_form_component(obj.animal_found_place),
              animal_age: URI.decode_www_form_component(obj.animal_age),
              animal_color: URI.decode_www_form_component(obj.animal_color)
            )
            animal_obj_hash[key] = obj
          end

          view 'project', locals: {
            animal_obj_hash:
          }
        end
      end

      routing.on 'adopt' do
        # POST /adopt
        routing.post do
          # Perform any necessary processing for the 'Adopt?' button click
          # ...
    
          # Render the 'adopt.slim' file
          view 'adopt'
    
          # Redirect to the desired page
        end
      end
      routing.on 'found' do
        routing.post do

        script_path = 'app/controllers/classification.py'

        output = Open3.capture2("python3 #{script_path}")
        view 'found', locals: {
          output:
        } # Assume you have an "upload.slim" file for the form

        end
      end


      routing.on 'missing' do
        # POST /adopt
        routing.post do
          # Perform any necessary processing for the 'Adopt?' button click
          # ...
    
          # Render the 'adopt.slim' file
          view 'missing'
    
          # Redirect to the desired page
        end
      end


  



    end
  end
end
