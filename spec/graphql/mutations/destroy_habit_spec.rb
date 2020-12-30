# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe DestroyHabit, type: :request do
    describe '.resolve' do
      let(:user) { create_user_with_habits }
      let(:auth_headers) { user.create_new_auth_token }

      it 'returns destroyed habit' do
        habit = user.habits.first
        post '/graphql', params: { query: destroy_habit_mutation(habit.id) }, headers: auth_headers
        habit_name = JSON.parse(response.body).dig('data', 'destroyHabit', 'habit', 'name')
        expect(habit_name).to eq(habit.name)
      end

      it 'habit is removed from database' do
        habit = user.habits.first
        post '/graphql', params: { query: destroy_habit_mutation(habit.id) }, headers: auth_headers
        expect(user.habits.find_by(id: habit.id)).to be_nil
      end

      it 'with incorrect ID UserInputError is thrown' do
        habit_id = user.habits.last.id + 1
        post '/graphql', params: { query: destroy_habit_mutation(habit_id) }, headers: auth_headers
        error_message = JSON.parse(response.body).dig('errors', 0, 'extensions', 'detailed_errors', 'id', 0)
        expect(error_message).to eq('is invalid')
      end

      it 'with no auth returns error' do
        habit_id = user.habits.last.id
        post '/graphql', params: { query: destroy_habit_mutation(habit_id) }
        error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
        expect(error_code).to eq('AUTHENTICATION_ERROR')
      end
    end
  end
end

def destroy_habit_mutation(habit_id)
  <<~GQL
    mutation {
    destroyHabit(habitId: #{habit_id}) {
        habit {
          id
          name
          startDate
        }
      }
    }
  GQL
end
