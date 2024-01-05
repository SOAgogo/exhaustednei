# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'json'
require 'uri'
require 'securerandom'
require 'fileutils'
require 'open3'
require 'pry'
module PetAdoption
  # for controller part

  # rubocop:disable Metrics/ClassLength
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets', group_subdirs: false,
                    css: 'style.css',
                    js: {
                      map: ['map.js'],
                      keeper: ['keeper.js']
                    }

    plugin :common_logger, $stderr
    plugin :json

    # use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS
      response['Content-Type'] = 'text/html; charset=utf-8'
      routing.public # load static files
      session[:map_key] = App.config.MAP_TOKEN

      # GET /
      routing.root do
        session[:watching] ||= {}
        routing.redirect '/home' if session[:watching]['name']
        flash.now[:notice] = 'Welcome web page' unless session[:watching]['name']

        view('signup')
      end

      routing.post 'signup' do
        url_request = Forms::UserDataValidator.new.call(routing.params.transform_keys(&:to_sym))
        if url_request.failure?
          session[:watching] = {}
          flash[:error] = Forms::HumanReadAble.error(url_request.errors.to_h)
          routing.redirect '/'
        end

        session[:watching] = routing.params
        routing.redirect '/home'
      end

      routing.on 'home' do
        routing.is do
          view 'home'
        rescue StandardError
          flash[:error] = 'Could not find the cover page.'
        end
      end

      routing.on 'animal' do
        routing.is do
          routing.post do
            begin
              animal_kind = routing.params['animal_kind'].downcase
              shelter_name = routing.params['shelter_name']
              if animal_kind != 'dog' && animal_kind != 'cat'
                flash[:error] = 'Please select animal kind correctly.'
                routing.redirect '/home'
              end
              if shelter_name.nil?
                flash[:error] = 'Dont leave shelter name blank.'
                routing.redirect '/home'
              end
              sn_ch = URI.decode_www_form_component(shelter_name)
            end
            routing.redirect "animal/#{animal_kind}/#{sn_ch}"
          end
        end

        routing.on String, String do |animal_kind, shelter_name|
          ak_ch = animal_kind == 'dog' ? '狗' : '貓'

          shelter_name = URI.decode_www_form_component(shelter_name)
          animal_kind = URI.decode_www_form_component(ak_ch)
          shelter_selector = Forms::ShelterSelector.new.call({ animal_kind:, shelter_name: })

          begin
            get_all_animals_in_shelter = Services::SelectAnimal.new.call(shelter_selector)
            crawded_ratio = Services::ShelterCapacityCounter.new.call(shelter_selector)
            old_animal_num = Services::NumberOfOldAnimals.new.call(shelter_selector)
            view_animals = PetAdoption::Views::AnimalInShelter.new(get_all_animals_in_shelter)
            view_crawded_ratio = PetAdoption::Views::ShelterCrowdedness.new(crawded_ratio)
            view_old_animal_num = PetAdoption::Views::Serverity.new(old_animal_num)

            view 'project', locals: {
              view_animals:,
              view_crawded_ratio:,
              view_old_animal_num:,
              shelter_name:
            }
          rescue StandardError
            # App.logger.error err.backtrace.join("DB can't find the results\n")
            flash[:error] = 'Could not find the results.'
            routing.redirect '/home'
          end
        end
      end

      routing.post 'user/count-animal-score' do
        routing.is do
          params = session[:watching].merge('animal_id' => routing.params['animalId'])

          user_preference = Forms::UserPreference.new.call(params.transform_keys(&:to_sym))

          response = Services::PickAnimalByOriginID.new.call(user_preference)

          view_obj = Views::ScoreForAnimal.new(response)

          return view_obj.value.to_json
        end
      rescue StandardError
        flash[:error] = 'Could not count the score.'
      end

      routing.on 'found' do
        view 'found'
      end

      routing.post 'finder/recommend-vets' do
        uploaded_file = routing.params['file0'][:tempfile].path if routing.params['file0'].is_a?(Hash)
        selected_keys = %w[name email phone]
        finder_info = session[:watching].slice(*selected_keys)
        finder_info['county'] = routing.params['county']
        finder_info['location'] = routing.params['location']
        finder_info['file'] = uploaded_file
        finder_info['distance'] = routing.params['distance']
        finder_info['number'] = routing.params['number']

        finder_preference = Forms::FinderInputsValidator.new.call(finder_info)

        res = Services::FinderUploadImages.new.call(finder_preference)

        instructions = PetAdoption::Views::TakeCareInfo.new(res)
        location_data = PetAdoption::Views::Clinic.new(res)

        view 'finder', locals: { location_data:, instructions: }
      rescue StandardError
        flash[:error] = 'Could not find the vets. Please try again.'
        routing.redirect '/found'
      end

      routing.on 'adopt' do
        view 'adopt'
      end

      routing.post 'promote-user-animals' do
        keys_to_exclude = %w[name email phone address]
        user_preference = session[:watching].except(*keys_to_exclude)
        ratio = routing.params.transform_keys { |key| "ratio_#{key}" }
        input = user_preference.merge(ratio)
        input = input.transform_keys { |key| key == 'ratio_top' ? 'top' : key }
        req = Forms::RecommendInputsValidator.new.call(input)

        output = Services::PromoteUserAnimals.new.call(req)
        if output.failure?
          flash[:error] = 'Recommendation failed, please try again.'
          routing.redirect '/adopt'
        end

        output_view = PetAdoption::Views::PromoteUserAnimals.new(output.value!)

        view 'recommendation', locals: { output: output_view }
      end

      routing.on 'missing' do
        view 'missing'
      end

      routing.post 'keeper/contact-finders' do
        uploaded_file = routing.params['file0'][:tempfile].path if routing.params['file0'].is_a?(Hash)
        selected_keys = %w[name email phone]
        keeper_info = session[:watching].slice(*selected_keys)
        keeper_info['county'] = routing.params['county']
        keeper_info['location'] = routing.params['location']
        keeper_info['file'] = uploaded_file
        keeper_info['searchcounty'] = routing.params['searchcounty']
        keeper_info['distance'] = routing.params['distance']

        keeper_preference = Forms::KeeperInputsValidator.new.call(keeper_info)

        # puts 'keeper_preference'
        res = Services::KeeperUploadImages.new.call(keeper_preference)

        information = PetAdoption::Views::LossingPets.new(res.value!)

        view 'keeper', locals: { information: }
      rescue StandardError
        flash[:error] = 'Sorry, in this moment, there is no lossing pet nearby you'
        routing.redirect '/missing'
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
