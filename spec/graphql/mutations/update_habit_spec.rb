# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateHabit, type: :request do
    describe '.resolve' do
      let(:user) { user_with_habits }
      let(:args) do
        { name: 'Run every day', description: 'Run everyday in the evening',
          type: 'goal', frequency: 'daily', start_date: Date.new }
      end
      let(:auth_headers) { user.create_new_auth_token }

      it 'creates a habit' do
        post '/graphql', params: { query: create_habit_mutation(**args) }, headers: auth_headers
        habit_id = JSON.parse(response.body).dig('data', 'createHabit', 'habit', 'id')
        expect(Habit.find(habit_id).name).to eq(args[:name])
      end

      it 'creates a habit with invalid params returns error' do
        args[:type] = 'goals'
        post '/graphql', params: { query: create_habit_mutation(**args) }, headers: auth_headers
        error_message = JSON.parse(response.body).dig('errors', 0, 'extensions', 'detailed_errors', 'habit_type', 0)
        expect(error_message).to eq("Must be either 'goal' or 'limit'")
      end

      it 'creates a habit with no auth returns error' do
        post '/graphql', params: { query: create_habit_mutation(**args) }
        error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
        expect(error_code).to eq('AUTHENTICATION_ERROR')
      end

      it 'update a habit returns updated habit' do
        request.headers = user.create_new_auth_token
        args[:name] = 'No coffee on week-ends'
        post '/graphql', params: { query: update_habit_mutation(user.habits.last.id, **args) }
        habit_name = JSON.parse(response.body).dig('data', 'updateHabit', 'habit', 'name')
        expect(habit_name).to eq(args[:name])
      end

      it 'updates a habit' do
        habit_id = user.habits.last.id
        request.headers = user.create_new_auth_token
        args[:name] = 'No coffee on week-ends'
        post '/graphql', params: { query: update_habit_mutation(habit_id, **args) }
        expect(Habit.find(habit_id).name).to eq(args[:name])
      end

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

def create_habit_mutation(**args)
  <<~GQL
    mutation {
    createHabit(name: "#{args[:name]}", description: "#{args[:description]}",
      habitType: "#{args[:type]}", frequency: "#{args[:frequency]}",
      startDate: "#{args[:start_date]}") {
        habit {
          id
          name
          startDate
        }
      }
    }
  GQL
end

def update_habit_mutation(habit_id, **args)
  <<~GQL
    mutation {
    updateHabit(id: #{habit_id}, name: "#{args[:name]}",
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
