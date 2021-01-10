# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateReminder, type: :request do
    describe '.resolve' do
      include_context 'shared methods'
      let(:args) do
        { habit_id: user.habits.first.id, remind_at: (DateTime.current + 2.hours).to_s }
      end
      let(:create_reminder_request) do
        post '/graphql', params: { query: create_reminder_mutation(**args) }, headers: auth_headers
      end

      context 'with valid params' do
        it 'creates a reminder' do
          expect { create_reminder_request }.to change(Reminder, :count).by(1)
        end

        it 'returns reminder payload' do
          create_reminder_request
          remind_at = JSON.parse(response.body).dig('data', 'createReminder', 'reminder', 'remindAt')
          expect(remind_at).not_to be_nil
        end

        it 'returns habit payload' do
          create_reminder_request
          habit_id = JSON.parse(response.body).dig('data', 'createReminder', 'reminder', 'habit', 'id')
          habit_name = JSON.parse(response.body).dig('data', 'createReminder', 'reminder', 'habit', 'name')
          expect(Habit.find(habit_id).name).to eq(habit_name)
        end
      end

      context 'without remind_at' do
        it 'ValidationError is raised' do
          args[:remind_at] = nil
          create_reminder_request
          expect(error_code).to eq('argumentLiteralsIncompatible')
        end
      end

      context 'with incorrect remind_at' do
        it 'ValidationError is raised' do
          args[:remind_at] = 'A far away time'
          create_reminder_request
          expect(error_code).to eq('argumentLiteralsIncompatible')
        end
      end

      context 'with no auth' do
        it 'AuthenticationError is raised' do
          post '/graphql', params: { query: create_reminder_mutation(**args) }
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end
  end
end

def create_reminder_mutation(**args)
  <<~GQL
    mutation {
    createReminder(habitId: "#{args[:habit_id]}", remindAt: "#{args[:remind_at]}") {
        reminder {
          id
          remindAt
          habit {
            id
            name
          }
        }
      }
    }
  GQL
end
