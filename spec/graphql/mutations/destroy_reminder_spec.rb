# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe DestroyReminder, type: :request do
    describe '.resolve' do
      include_context 'shared methods'
      let(:reminders) { create_list(:reminder, 2, habit: user.habits.first) }
      let(:destroy_reminder_request) do
        post '/graphql', params: { query: destroy_reminder_mutation(reminder_id: reminders.first.id) }, headers: auth_headers
      end

      context 'with valid device ID' do
        it 'returns destroyed device' do
          destroy_reminder_request
          device_id = JSON.parse(response.body).dig('data', 'destroyReminder', 'reminder', 'id')
          expect(device_id).not_to be_nil
        end

        it 'destroys device' do
          reminders
          expect { destroy_reminder_request }.to change(Reminder, :count).by(-1)
        end
      end

      context 'with invalid ID' do
        it 'UserInputError is raised' do
          post '/graphql', params: { query: destroy_reminder_mutation(reminder_id: Faker::Internet.uuid) }, headers: auth_headers
          expect(error_code).to eq('USER_INPUT_ERROR')
        end
      end

      context 'with user without access to habit' do
        it 'ForbiddenError is raised' do
          post '/graphql', params: { query: destroy_reminder_mutation(reminder_id: reminders.first.id) }, headers: forbidden_auth_headers
          expect(error_code).to eq('FORBIDDEN_ERROR')
        end
      end

      context 'with not logged in user' do
        it 'returns error' do
          post '/graphql', params: { query: destroy_reminder_mutation(reminder_id: reminders.first.id) }
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end
  end
end

def destroy_reminder_mutation(reminder_id:)
  <<~GQL
    mutation {
    destroyReminder(reminderId: "#{reminder_id}") {
        reminder {
          id
          remindAt
        }
      }
    }
  GQL
end
