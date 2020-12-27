# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe UpdateHabit, type: :request do
    describe '.resolve' do
      let(:user) { user_with_habits }
      let(:args) do
        { name: 'Run every day', description: 'Run everyday in the evening',
          type: 'goal', frequency: 'daily', start_date: Date.new }
      end
      let(:auth_headers) { user.create_new_auth_token }

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
    end
  end
end

def update_habit_mutation(habit_id, **args)
  <<~GQL
    mutation {
    updateHabit(id: #{habit_id}, name: "#{args[:name]}", active: "#{args[:active]}",
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
