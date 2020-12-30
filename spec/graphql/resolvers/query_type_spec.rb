# frozen_string_literal: true

require 'rails_helper'

module Types
  RSpec.describe QueryType, type: :request do
    describe '.resolve' do
      let(:user) { create_user_with_habits }
      let(:args) do
        { frequency: ['daily'], active: true, selected_date: '2020-12-28' }
      end
      let(:auth_headers) { user.create_new_auth_token }

      before do
        create_habit_with_logs(5, user.habits.first)
      end

      it 'returns daily habits' do
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        habits_array = JSON.parse(response.body).dig('data', 'habitIndex')
        expect(habits_array.length).to eq(5)
      end

      it 'returns habit logs' do
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        habit_logs = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'habitLogs')
        expect(habit_logs.length).to eq(5)
      end

      it 'returns logged for habit' do
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        is_logged = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'isLogged')
        expect(is_logged).to be_truthy
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
        isLogged(selectedDate: "#{args[:selected_date]}")
        habitLogs {
          id
          loggedDate
        }
      }
    }
  GQL
end
