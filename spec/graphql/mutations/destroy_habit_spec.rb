# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe DestroyHabit, type: :request do
    describe '.resolve' do
      include_context 'shared methods'

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
        expect(error_code).to eq('USER_INPUT_ERROR')
      end

      it 'with no auth returns error' do
        habit_id = user.habits.last.id
        post '/graphql', params: { query: destroy_habit_mutation(habit_id) }
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
