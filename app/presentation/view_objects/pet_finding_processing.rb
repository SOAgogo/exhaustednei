# frozen_string_literal: true

module PetAdoption
  module Views
    # View object to capture progress bar information
    class PetFindingProcessing
      def initialize(config, response)
        @response = response
        @config = config
      end

      def in_progress?
        @response.status == 'processing'
      end

      def ws_channel_id
        @response.message['request_id'] if in_progress?
      end

      def ws_javascript
        # @config.API_HOST + '/faye/faye.js' if in_progress?
        @config.API_HOST + '/faye/faye.js' if in_progress?
      end

      def ws_route
        @config.API_HOST + '/faye/faye' if in_progress?
      end
    end
  end
end
