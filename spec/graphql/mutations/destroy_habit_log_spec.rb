# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe DestroyHabitLog, type: :request do
    describe '.resolve' do
      let(:user) { create_user_with_habits }
      let(:forbidden_user) { create(:user) }
      let(:auth_headers) { user.create_new_auth_token }
      let(:forbidden_auth_headers) { forbidden_user.create_new_auth_token }

      before do
        create_habit_with_logs(5, user.habits.first)
      end

      it 'returns destroyed habit log' do
        habit_log = HabitLog.first
        post '/graphql', params: { query: destroy_habit_log_mutation(habit_log.id) }, headers: auth_headers
        habit_log_id = JSON.parse(response.body).dig('data', 'destroyHabitLog', 'habitLog', 'id')
        expect(habit_log_id.to_i).to eq(habit_log.id)
      end

      it 'habit log is removed from database' do
        habit_log = HabitLog.first
        post '/graphql', params: { query: destroy_habit_log_mutation(habit_log.id) }, headers: auth_headers
        expect(HabitLog.find_by(id: habit_log.id)).to be_nil
      end

      it 'with incorrect ID UserInputError is raised' do
        habit_log_id = HabitLog.last.id + 100
        post '/graphql', params: { query: destroy_habit_log_mutation(habit_log_id) }, headers: auth_headers
        error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
        expect(error_code).to eq('USER_INPUT_ERROR')
      end

      it 'with user without access to habit ForbiddenError is raised' do
        habit_log_id = HabitLog.last.id
        post '/graphql', params: { query: destroy_habit_log_mutation(habit_log_id) }, headers: forbidden_auth_headers
        error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
        expect(error_code).to eq('FORBIDDEN_ERROR')
      end

      it 'with no auth returns error' do
        habit_log_id = HabitLog.last.id
        post '/graphql', params: { query: destroy_habit_log_mutation(habit_log_id) }
        error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
        expect(error_code).to eq('AUTHENTICATION_ERROR')
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
