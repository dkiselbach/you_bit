# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe DestroyDevice, type: :request do
    describe '.resolve' do
      include_context 'shared methods'
      let(:devices) { create_list(:device, 2, user: user) }
      let(:destroy_device_request) do
        post '/graphql', params: { query: destroy_device_mutation(device_token: devices.first.token) },
                         headers: auth_headers
      end

      context 'with valid device ID' do
        it 'returns destroyed device' do
          destroy_device_request
          device_id = JSON.parse(response.body).dig('data', 'destroyDevice', 'device', 'id')
          expect(device_id).not_to be_nil
        end

        it 'destroys device' do
          devices
          expect { destroy_device_request }.to change(Device, :count).by(-1)
        end
      end

      context 'with invalid ID' do
        it 'UserInputError is raised' do
          post '/graphql', params: { query: destroy_device_mutation(device_token: Faker::Internet.uuid) },
                           headers: auth_headers
          expect(error_code).to eq('USER_INPUT_ERROR')
        end
      end

      context 'with user without access to habit' do
        it 'ForbiddenError is raised' do
          post '/graphql', params: { query: destroy_device_mutation(device_token: devices.first.token) },
                           headers: forbidden_auth_headers
          expect(error_code).to eq('FORBIDDEN_ERROR')
        end
      end

      context 'with not logged in user' do
        it 'returns error' do
          post '/graphql', params: { query: destroy_device_mutation(device_token: devices.first.token) }
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end
  end
end

def destroy_device_mutation(device_token:)
  <<~GQL
    mutation {
    destroyDevice(token: "#{device_token}") {
        device {
          id
          platform
        }
      }
    }
  GQL
end
