# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateHabitLog, type: :request do
    describe '.resolve' do
      include_context 'shared methods'
      let(:args) do
        { habit_id: user.habits.first.id, logged_date: Date.new, habit_type: 'goal' }
      end
      let(:create_habit_request) do
        post '/graphql', params: { query: create_habit_log_mutation(**args) }, headers: auth_headers
      end

      context 'with valid params' do
        before do
          create_habit_request
        end

        it 'returns habitLog payload' do
          habit_log_id = JSON.parse(response.body).dig('data', 'createHabitLog', 'habitLog', 'id')
          expect(HabitLog.find(habit_log_id).habit_id).to eq(args[:habit_id])
        end

        it 'returns habit payload' do
          habit_id = JSON.parse(response.body).dig('data', 'createHabitLog', 'habitLog', 'habit', 'id')
          habit_name = JSON.parse(response.body).dig('data', 'createHabitLog', 'habitLog', 'habit', 'name')
          expect(Habit.find(habit_id).name).to eq(habit_name)
        end
      end

      context 'with invalid habit_type' do
        it 'ValidationError is raised' do
          args[:habit_type] = 'aspiration'
          create_habit_request
          expect(error_code).to eq('VALIDATION_ERROR')
        end
      end

      context 'with invalid id' do
        it 'UserInputError is raised' do
          args[:habit_id] = Habit.last.id + 100
          create_habit_request
          expect(error_code).to eq('USER_INPUT_ERROR')
        end
      end

      context 'with no auth' do
        it 'AuthenticationError is raised' do
          post '/graphql', params: { query: create_habit_log_mutation(**args) }
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end

      context 'with user without access to habit' do
        it 'ForbiddenError is raised' do
          post '/graphql', params: { query: create_habit_log_mutation(**args) },
                           headers: forbidden_auth_headers
          expect(error_code).to eq('FORBIDDEN_ERROR')
        end
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
