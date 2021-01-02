# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe UpdateHabit, type: :request do
    describe '.resolve' do
      subject(:error_code) { JSON.parse(response.body).dig('errors', 0, 'extensions', 'code') }

      let(:user) { create_user_with_habits }
      let(:args) do
        { name: 'Run every day', description: 'Run everyday in the evening',
          type: 'goal', frequency: 'daily', start_date: Date.new }
      end
      let(:auth_headers) { user.create_new_auth_token }
      let(:forbidden_user) { create(:user) }
      let(:forbidden_auth_headers) { forbidden_user.create_new_auth_token }

      context 'with valid habit ID' do
        it 'returns updated habit' do
          args[:name] = 'No coffee on week-ends'
          post '/graphql', params: { query: update_habit_mutation(user.habits.last.id, **args) }, headers: auth_headers
          habit_name = JSON.parse(response.body).dig('data', 'updateHabit', 'habit', 'name')
          expect(habit_name).to eq(args[:name])
        end

        it 'updates a habit' do
          habit_id = user.habits.last.id
          args[:name] = 'No coffee on week-ends'
          post '/graphql', params: { query: update_habit_mutation(habit_id, **args) }, headers: auth_headers
          expect(Habit.find(habit_id).name).to eq(args[:name])
        end
      end

      context 'when user not logged in' do
        it 'returns error' do
          habit_id = user.habits.last.id
          post '/graphql', params: { query: update_habit_mutation(habit_id, **args) }
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end

      context 'with invalid ID' do
        it 'UserInputError is raised' do
          post '/graphql', params: { query: update_habit_mutation(user.habits.last.id + 100, **args) }, headers: auth_headers
          expect(error_code).to eq('USER_INPUT_ERROR')
        end
      end

      context 'with user without access to habit' do
        it 'ForbiddenError is raised' do
          post '/graphql', params: { query: update_habit_mutation(user.habits.last.id, **args) },
                           headers: forbidden_auth_headers
          expect(error_code).to eq('FORBIDDEN_ERROR')
        end
      end
    end
  end
end

def update_habit_mutation(habit_id, **args)
  <<~GQL
    mutation {
    updateHabit(habitId: #{habit_id}, name: "#{args[:name]}",
      description: "#{args[:description]}", habitType: "#{args[:type]}",
      frequency: "#{args[:frequency]}", startDate: "#{args[:start_date]}" ) {
        habit {
          id
          name
          startDate
        }
      }
    }
  GQL
end
