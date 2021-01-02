# frozen_string_literal: true

require 'rails_helper'

module Types
  RSpec.describe QueryType, type: :request do
    let!(:user) { create_user_with_habits }
    let(:auth_headers) { user.create_new_auth_token }

    describe '.habit_index' do
      let(:args) do
        { frequency: ['daily'], active: true, selected_date: '2020-12-29' }
      end

      let!(:habit_logs) do
        %w[2020-12-29 2020-12-30 2020-12-31 2021-01-01 2021-01-02].each do |date|
          FactoryBot.create(:habit_log, logged_date: date, habit: user.habits.first)
        end
      end

      context 'with frequency set to daily' do
        it 'returns daily habits' do
          post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
          habits_array = JSON.parse(response.body).dig('data', 'habitIndex')
          expect(habits_array.length).to eq(5)
        end
      end

      context 'when habit has logs' do
        it 'returns habit logs' do
          post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
          habit_logs = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'habitLogs')
          expect(habit_logs.length).to eq(5)
        end
      end

      context 'when habit is logged on selected date' do
        it 'returns true for logged' do
          post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
          is_logged = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'isLogged', 'logged')
          expect(is_logged).to be_truthy
        end

        it 'returns habit log for logged' do
          post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
          habit_log = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'isLogged', 'habitLog')
          expect(habit_log['id'].to_i).to eq(HabitLog.find_by(logged_date: '2020-12-29').id)
        end
      end

      it 'returns longest streak for habit' do
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        longest_streak = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'longestStreak', 'habitStreak')
        expect(longest_streak).to eq(5)
      end

      it 'returns current streak for habit' do
        args[:selected_date] = '2020-12-31'
        post '/graphql', params: { query: habits_index_query(**args) }, headers: auth_headers
        current_streak = JSON.parse(response.body).dig('data', 'habitIndex', 0, 'currentStreak', 'habitStreak')
        expect(current_streak).to eq(3)
      end

      context 'when not logged in' do
        it 'returns authorization error' do
          post '/graphql', params: { query: habits_index_query(**args) }
          error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end

    describe '.user' do
      context 'when logged in' do
        it 'returns name' do
          post '/graphql', params: { query: user_query }, headers: auth_headers
          user_name = JSON.parse(response.body).dig('data', 'user', 'name')
          expect(user_name).to eq(user.name)
        end
      end

      context 'when not logged in' do
        it 'returns authorization error' do
          post '/graphql', params: { query: user_query }
          error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end

    describe '.habit' do
      subject(:habit) { user.habits.first }

      context 'with habit ID' do
        it 'returns habit name' do
          post '/graphql', params: { query: habit_query(habit_id: habit.id) }, headers: auth_headers
          habit_name = JSON.parse(response.body).dig('data', 'habit', 'name')
          expect(habit_name).to eq(habit.name)
        end

        it 'returns habit id' do
          post '/graphql', params: { query: habit_query(habit_id: habit.id) }, headers: auth_headers
          habit_id = JSON.parse(response.body).dig('data', 'habit', 'id')
          expect(habit_id.to_i).to eq(habit.id)
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

      context 'when not logged in' do
        it 'returns authorization error' do
          post '/graphql', params: { query: habit_query(habit_id: habit.id) }
          error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end

    describe '.categoriesIndex' do
      subject(:category) { user.categories.first }

      context 'when user has categories through habits' do
        it 'returns category name' do
          post '/graphql', params: { query: categories_index_query }, headers: auth_headers
          category_name = JSON.parse(response.body).dig('data', 'categoriesIndex', 0, 'name')
          expect(category_name).to eq(category.name)
        end

        it 'returns category id' do
          post '/graphql', params: { query: categories_index_query }, headers: auth_headers
          category_id = JSON.parse(response.body).dig('data', 'categoriesIndex', 0, 'id')
          expect(category_id.to_i).to eq(category.id)
        end
      end

      context 'when not logged in' do
        it 'returns authorization error' do
          post '/graphql', params: { query: categories_index_query }
          error_code = JSON.parse(response.body).dig('errors', 0, 'extensions', 'code')
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end
  end
end

def habits_index_query(**args)
  <<~GQL
    query {
      habitIndex(daysOfWeek: #{args[:frequency]}, active: #{args[:active]}) {
        name
        description
        startDate
        active
        isLogged(selectedDate: "#{args[:selected_date]}") {
          logged
          habitLog {
            id
          }
        }
        longestStreak {
          habitStreak
          startDate
          endDate
        }
        currentStreak(selectedDate: "#{args[:selected_date]}") {
          habitStreak
          startDate
          endDate
        }
        habitLogs {
          id
          loggedDate
        }
      }
    }
  GQL
end

def user_query
  <<~GQL
    query {
      user {
        id
        name
        email
      }
    }
  GQL
end

def habit_query(habit_id:)
  <<~GQL
    query {
      habit(habitId: "#{habit_id}") {
        id
        name
      }
    }
  GQL
end

def categories_index_query
  <<~GQL
    query {
      categoriesIndex {
        id
        name
      }
    }
  GQL
end
