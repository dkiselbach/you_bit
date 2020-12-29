# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateHabitLog, type: :request do
    describe '.resolve' do
      let(:user) { create_user_with_habits }
      let(:args) do
        { habit_id: Habit.first.id, logged_date: Date.new }
      end
      let(:auth_headers) { user.create_new_auth_token }

      it 'creates a habit log' do
        post '/graphql', params: { query: create_habit_mutation(**args) }, headers: auth_headers
        habit_id = JSON.parse(response.body).dig('data', 'createHabit', 'habit', 'id')
        expect(Habit.find(habit_id).name).to eq(args[:name])
      end

      describe ''
      it 'with invalid params returns error' do
        args[:type] = 'goals'
        post '/graphql', params: { query: create_habit_mutation(**args) }, headers: auth_headers
        error_message = JSON.parse(response.body).dig('errors', 0, 'extensions', 'detailed_errors', 'habit_type', 0)
        expect(error_message).to eq("Must be either 'goal' or 'limit'")
      end

      it 'with no auth returns error' do
        post '/graphql', params: { query: create_habit_mutation(**args) }
        error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
        expect(error_code).to eq('AUTHENTICATION_ERROR')
      end
    end
  end
end

def create_habit_log_mutation(**args)
  <<~GQL
    mutation {
    createHabitLog(habitId: "#{args[:habit_id]}", loggedDate: "#{args[:logged_date]}") {
        habit {
          id
          name
          startDate
        }
      }
    }
  GQL
end
