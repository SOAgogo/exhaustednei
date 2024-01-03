# frozen_string_literal: true

# test the data coming from gateway api are the same as the data in the database
require_relative '../../helpers/vcr_helper'
require 'uri'
require 'json'

describe 'Test Gpt API' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_website
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Unit test of ChatGPT API' do
    before do
      # load the messages from text_messages/text.yml
      @messages = JSON.parse(File.read('spec/tests/unit/test_messages/messages.json'))
      @answers = JSON.parse(File.read('spec/tests/unit/test_messages/text_answers.json'))

      @pictures = JSON.parse(File.read('spec/tests/unit/picture_messages/picture_messages.json'))
    end
    it 'it should provide the key words as same as user inputs' do
      @messages['queries'].each_with_index do |message, index|
        output = PetAdoption::GptConversation::Conversation.new(message['query']).generate_words
        correct = @answers[index]['tallest_building'].values
        correct.each do |value|
          _(output).must_include(value.to_s.reverse.scan(/\d{3}|.+/).join(',').reverse)
        end
      end
    end

    it 'it should provide the pictures information of animal breeds' do
      @pictures.each do |query|
        image_conversation = PetAdoption::GptConversation::ImageConversation.new
        image_conversation.image_path(query['image_path'])
        output = image_conversation.generate_words_by_star_sign(query['birth_date'])
        contain_probability = true if output =~ /\d/
        _(contain_probability).must_equal(true)
      end
    end
  end
end
