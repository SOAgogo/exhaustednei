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
          animal_pic = Services::PickAnimalCover.new.call
          cover_page = PetAdoption::Views::Picture.new(animal_pic.value![:cover]).cover
          view 'home', locals: { image_url: cover_page }
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
          begin
            get_all_animals_in_shelter = Services::SelectAnimal.new.call({ shelter_name:,
                                                                           animal_kind: })

            crawded_ratio = Services::ShelterCapacityCounter.new.call({ shelter_name: }).value![:output]

            view_obj = PetAdoption::Views::ChineseWordsCanBeEncoded.new(
              get_all_animals_in_shelter.value![:animal_obj_list]
            )
            view 'project', locals: {
              view_obj:,
              crawded_ratio:,
              shelter_name:
            }
          rescue StandardError
            # App.logger.error err.backtrace.join("DB can't find the results\n")
            flash[:error] = 'Could not find the results.'
            routing.redirect '/home'
          end
        end
      end

      routing.on 'found' do
        view 'found'
      end

      routing.post 'finder/recommend-vets' do
        uploaded_file = routing.params['file0'][:tempfile].path if routing.params['file0'].is_a?(Hash)

        selected_keys = %w[name email phone address]
        finder_info = session[:watching].slice(*selected_keys).transform_keys(&:to_sym)
        finder_info[:county] = routing.params['county']
        finder_info.delete(:address)
        finder_info[:location] = "#{routing.params['location']},#{finder_info[:county]}"
        finder_info[:file] = uploaded_file
        finder_info[:number] = routing.params['number'].to_i
        finder_info[:distance] = routing.params['distance'].to_i

        res = Services::FinderUploadImages.new.call({ finder_info: })

        instructions = PetAdoption::Views::TakeCareInfo.new(res.value![:finder])
        location_data = PetAdoption::Views::Clinic.new(res.value![:finder])

        view 'finder', locals: { location_data:, instructions: }
      rescue StandardError
        flash[:error] = 'Could not find the vets. Please try again.'
        routing.redirect '/found'
      end

      routing.on 'adopt' do
        view 'adopt'
      end

      routing.post 'user/count-animal-score' do
        routing.is do
          selected_keys = %w[name email phone address birthdate]
          user_preference = session[:watching].except(*selected_keys).transform_keys(&:to_sym)
          user_preference[:sterilized] = user_preference[:sterilized] == 'yes'
          user_preference[:vaccinated] = user_preference[:vaccinated] == 'yes'
          feature_user_want_ratio = [age: 1, sterilized: 1, bodytype: 1, sex: 1, vaccinated: 1, species: 1, color: 1]
          input = [routing.params['animalId'].to_i, user_preference, feature_user_want_ratio]
          binding.pry

          response = Services::PickAnimalByOriginID.new.call({ input: })

          return response.value!
        end
      rescue StandardError
        flash[:error] = 'Could not count the score.'
      end

      routing.post 'promote-user-animals' do
        keys_to_exclude = %w[name email phone birthdate address]
        user_preference = session[:watching].except(*keys_to_exclude)
        county = session[:watching]['address'][0..2]

        user_preference['county'] = county if routing.params['searchcounty'] == 'yes'

        input = [user_preference, routing.params]

        output = Services::PromoteUserAnimals.new.call(input)
        prefer_animals = output.value![:sorted_animals]

        if output.failure?
          flash[:error] = 'Recommendation failed, please try again.'
          routing.redirect '/adopt'
        end

        output_view = PetAdoption::Views::AnimalPromotion.new(prefer_animals)

        view 'recommendation', locals: { output: output_view }
      end

      routing.on 'missing' do
        view 'missing'
      end

      routing.post 'keeper/contact-finders' do
        uploaded_file = routing.params['file0'][:tempfile].path if routing.params['file0'].is_a?(Hash)

        selected_keys = %w[name email phone address]
        keeper_info = session[:watching].slice(*selected_keys).transform_keys(&:to_sym)
        keeper_info.delete(:address)
        keeper_info[:county] = routing.params['county']

        keeper_info[:location] = routing.params['location']
        keeper_info[:file] = uploaded_file
        keeper_info[:bodytype] = routing.params['bodytype']
        keeper_info[:hair] = routing.params['hair']
        keeper_info[:species] = routing.params['species']
        keeper_info[:searchcounty] = routing.params['searchcounty'] == 'yes'
        keeper_info[:distance] = routing.params['distance'].to_i

        res = Services::KeeperUploadImages.new.call({ keeper_info: })

        information = PetAdoption::Views::LossingPets.new(res.value![:keeper])

        view 'keeper', locals: { information: }
      rescue StandardError
        flash[:error] = 'Sorry, in this moment, there is no lossing pet nearby you'
        routing.redirect '/missing'
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
