# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateHabit, type: :request do
    describe '.resolve' do
      include_context 'shared methods'
      let(:args) do
        { name: 'Run every day', description: 'Run everyday in the evening',
          type: 'goal', frequency: ['daily'], start_date: Date.new,
          category_name: 'We like sports!' }
      end

      it 'creates a habit' do
        post '/graphql', params: { query: create_habit_mutation(**args) }, headers: auth_headers
        habit_id = JSON.parse(response.body).dig('data', 'createHabit', 'habit', 'id')
        expect(Habit.find(habit_id).name).to eq(args[:name])
      end

      it 'creates a category if no category found' do
        habits
        expect do
          post '/graphql', params: { query: create_habit_mutation(**args) },
                           headers: auth_headers
        end.to change(Category, :count).by(1)
      end

      it 'associates a category if category found' do
        category = Category.create(name: 'sports')
        args[:category_name] = 'sports'
        post '/graphql', params: { query: create_habit_mutation(**args) }, headers: auth_headers
        category_id = JSON.parse(response.body).dig('data', 'createHabit', 'habit', 'category', 'id')
        expect(category_id.to_i).to eq(category.id)
      end

      it 'with invalid params returns error' do
        args[:type] = 'goals'
        post '/graphql', params: { query: create_habit_mutation(**args) }, headers: auth_headers
        expect(error_code).to eq('VALIDATION_ERROR')
      end

      it 'with no auth returns error' do
        post '/graphql', params: { query: create_habit_mutation(**args) }
        expect(error_code).to eq('AUTHENTICATION_ERROR')
      end
    end
  end
end

def create_habit_mutation(**args)
  <<~GQL
    mutation {
    createHabit(name: "#{args[:name]}", description: "#{args[:description]}",
      habitType: "#{args[:type]}", frequency: #{args[:frequency]},
      startDate: "#{args[:start_date]}", categoryName: "#{args[:category_name]}") {
        habit {
          id
          name
          startDate
          category {
            id
            name
          }
        }
      }
    }
  GQL
end
