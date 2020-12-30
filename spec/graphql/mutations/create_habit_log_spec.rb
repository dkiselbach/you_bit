# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateHabitLog, type: :request do
    describe '.resolve' do
      let!(:user) { create_user_with_habits }
      let(:args) do
        { habit_id: Habit.first.id, logged_date: Date.new, habit_type: "goal" }
      end
      let(:auth_headers) { user.create_new_auth_token }

      describe 'creates a habit log' do
        it 'returns habitLog payload' do
          post '/graphql', params: { query: create_habit_log_mutation(**args) }, headers: auth_headers
          habit_log_id = JSON.parse(response.body).dig('data', 'createHabitLog', 'habitLog', 'id')
          expect(HabitLog.find(habit_log_id).habit_id).to eq(args[:habit_id])
        end

        it 'returns habit payload' do
          post '/graphql', params: { query: create_habit_log_mutation(**args) }, headers: auth_headers
          habit_id = JSON.parse(response.body).dig('data', 'createHabitLog', 'habitLog', 'habit', 'id')
          habit_name = JSON.parse(response.body).dig('data', 'createHabitLog', 'habitLog', 'habit', 'name')
          expect(Habit.find(habit_id).name).to eq(habit_name)
        end
      end

      it 'with invalid params returns error' do
        args[:habit_type] = 'aspiration'
        post '/graphql', params: { query: create_habit_log_mutation(**args) }, headers: auth_headers
        error_message = JSON.parse(response.body).dig('errors', 0, 'extensions', 'detailed_errors', 'habit_type', 0)
        expect(error_message).to eq("Must be either 'goal' or 'limit'")
      end

      it 'with invalid id returns error' do
        args[:habit_id] = Habit.last.id + 100
        post '/graphql', params: { query: create_habit_log_mutation(**args) }, headers: auth_headers
        error_message = JSON.parse(response.body).dig('errors', 0, 'message')
        expect(error_message).to eq('Habit not found')
      end

      it 'with no auth returns error' do
        post '/graphql', params: { query: create_habit_log_mutation(**args) }
        error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
        expect(error_code).to eq('AUTHENTICATION_ERROR')
      end
    end
  end
end

def create_habit_log_mutation(**args)
  <<~GQL
    mutation {
    createHabitLog(habitId: "#{args[:habit_id]}", loggedDate: "#{args[:logged_date]}", habitType: "#{args[:habit_type]}") {
        habitLog {
          id
          loggedDate
          habitType
          habit {
            id
            name
            startDate
          }
        }
      }
    }
  GQL
end
