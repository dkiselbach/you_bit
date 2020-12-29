# frozen_string_literal: true

require 'rails_helper'

module Types
  RSpec.describe QueryType, type: :request do
    describe '.resolve' do
      let(:user) { create_user_with_habits }
      let(:args) do
        { frequency: ['daily'], active: true }
      end
      let(:auth_headers) { user.create_new_auth_token }

      it 'returns daily habits' do
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        habits_array = JSON.parse(response.body).dig('data', 'habitIndex')
        expect(habits_array.length).to eq(5)
      end
    end
  end
end

def habits_index_query(**args)
  <<~GQL
    query {
      habitIndex(daysOfWeek: #{args[:frequency]}, active: #{args[:active]}) {
        name
        description
        startDate
        active
      }
    }
  GQL
end
