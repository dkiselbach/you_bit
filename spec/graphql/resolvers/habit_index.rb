# frozen_string_literal: true

require 'rails_helper'

module Resolvers
  RSpec.describe 'Habit Index', type: :request do
    describe '.resolve' do
      let(:user) { user_with_habits }
      let(:args) do
        { frequency: ['daily'], active: true }
      end
      let(:auth_headers) { user.create_new_auth_token }

      it 'returns credentials' do
        user.habits.first.frequency = ['monday']
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        access_token = JSON.parse(response.body).dig('data', 'habitsIndex', 'name')
        expect(access_token).to be_a(String)
      end
    end
  end
end

def habits_index_query(**args)
  <<~GQL
    query {
      habitsIndex(frequency: #{args[:frequency]}", active: #{args[:active]}) {
        name
        description
        startDate
        active
      }
    }
  GQL
end
