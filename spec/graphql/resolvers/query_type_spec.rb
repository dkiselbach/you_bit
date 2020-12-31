# frozen_string_literal: true

require 'rails_helper'

module Types
  RSpec.describe QueryType, type: :request do
    describe '.resolve' do
      let!(:user) { create_user_with_habits }
      let(:args) do
        { frequency: ['daily'], active: true, selected_date: '2020-12-29' }
      end
      let(:auth_headers) { user.create_new_auth_token }

      before do
        %w[2020-12-29 2020-12-30 2020-12-31 2021-01-01 2021-01-02].each do |date|
          FactoryBot.create(:habit_log, logged_date: date, habit: user.habits.first)
        end
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
        is_logged = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'isLogged', 'logged')
        expect(is_logged).to be_truthy
      end

      it 'returns habit log for logged' do
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        habit_log = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'isLogged', 'habitLog')
        expect(habit_log['id'].to_i).to eq(HabitLog.find_by(logged_date: '2020-12-29').id)
      end

      it 'returns longest streak for habit' do
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        longest_streak = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'longestStreak', 'habitStreak')
        expect(longest_streak).to eq(5)
      end

      it 'returns current streak for habit' do
        args[:selected_date] = '2020-12-31'
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        current_streak = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'currentStreak', 'habitStreak')
        expect(current_streak).to eq(3)
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
        isLogged(selectedDate: "#{args[:selected_date]}") {
          logged
          habitLog {
            id
          }
        }
        longestStreak {
          habitStreak
          startDate
          endDate
        }
        currentStreak(selectedDate: "#{args[:selected_date]}") {
          habitStreak
          startDate
          endDate
        }
        habitLogs {
          id
          loggedDate
        }
      }
    }
  GQL
end
