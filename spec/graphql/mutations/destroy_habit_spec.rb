# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe DestroyHabit, type: :request do
    describe '.resolve' do
      let(:user) { user_with_habits }
      let(:args) do
        { name: 'Run every day', description: 'Run everyday in the evening',
          type: 'goal', frequency: 'daily', start_date: Date.new }
      end
      let(:auth_headers) { user.create_new_auth_token }

      it 'destroy a habit returns destroyed habit' do
        habit = user.habits.first
        request.headers = user.create_new_auth_token
        post '/graphql', params: { query: destroy_habit_mutation(habit.id) }
        habit_name = JSON.parse(response.body).dig('data', 'updateHabit', 'habit', 'name')
        expect(habit_name).to eq(habit.name)
      end

      it 'destroyed habit is removed from database' do
        habit = user.habits.first
        request.headers = user.create_new_auth_token
        post '/graphql', params: { query: destroy_habit_mutation(habit.id) }
        expect(user.habits.find(habit.id)).to raise_error
      end
    end
  end
end

def destroy_habit_mutation(habit_id)
  <<~GQL
    mutation {
    destroyHabit(id: #{habit_id}) {
        habit {
          id
          name
          startDate
        }
      }
    }
  GQL
end
