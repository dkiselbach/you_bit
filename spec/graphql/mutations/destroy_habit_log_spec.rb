# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe DestroyHabitLog, type: :request do
    describe '.resolve' do
      include_context 'shared methods'

      context 'with valid habit ID' do
        it 'returns destroyed habit log' do
          post '/graphql', params: { query: destroy_habit_log_mutation(habits.last.id) }, headers: auth_headers
          habit_log_id = JSON.parse(response.body).dig('data', 'destroyHabitLog', 'habitLog', 'id')
          expect(habit_log_id.to_i).to eq(habits.last.id)
        end

        it 'habit log is removed from database' do
          post '/graphql', params: { query: destroy_habit_log_mutation(habits.last.id) }, headers: auth_headers
          expect(HabitLog.find_by(id: habits.last.id)).to be_nil
        end
      end

      context 'with invalid ID' do
        it 'UserInputError is raised' do
          post '/graphql', params: { query: destroy_habit_log_mutation(habits.last.id + 100) }, headers: auth_headers
          error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
          expect(error_code).to eq('USER_INPUT_ERROR')
        end
      end

      context 'with user without access to habit' do
        it 'ForbiddenError is raised' do
          post '/graphql', params: { query: destroy_habit_log_mutation(habits.last.id) }, headers: forbidden_auth_headers
          error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
          expect(error_code).to eq('FORBIDDEN_ERROR')
        end
      end

      context 'with not logged in user' do
        it 'returns error' do
          post '/graphql', params: { query: destroy_habit_log_mutation(habits.last.id) }
          error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end
  end
end

def destroy_habit_log_mutation(habit_log_id)
  <<~GQL
    mutation {
    destroyHabitLog(habitLogId: #{habit_log_id}) {
        habitLog {
          id
          loggedDate
        }
      }
    }
  GQL
end
