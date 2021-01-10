# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe CreateDevice, type: :request do
    describe '.resolve' do
      include_context 'shared methods'
      let(:args) do
        { token: Faker::Internet.uuid, platform: 'iOS', client_identifier: "Dylan's iPhone" }
      end
      let(:create_device_request) do
        post '/graphql', params: { query: create_device_mutation(**args) }, headers: auth_headers
      end

      context 'with valid params' do
        it 'creates a device' do
          expect { create_device_request }.to change(Device, :count).by(1)
        end

        it 'returns device payload' do
          create_device_request
          device_id = JSON.parse(response.body).dig('data', 'createDevice', 'device', 'id')
          client_identifier = JSON.parse(response.body).dig('data', 'createDevice', 'device', 'clientIdentifier')
          expect(Device.find(device_id).client_identifier).to eq(client_identifier)
        end

        it 'returns user payload' do
          create_device_request
          user_id = JSON.parse(response.body).dig('data', 'createDevice', 'device', 'user', 'id')
          user_name = JSON.parse(response.body).dig('data', 'createDevice', 'device', 'user', 'name')
          expect(User.find(user_id).name).to eq(user_name)
        end
      end

      context 'without platform' do
        it 'ValidationError is raised' do
          args[:platform] = nil
          create_device_request
          expect(error_code).to eq('VALIDATION_ERROR')
        end
      end

      context 'with incorrect platform' do
        it 'ValidationError is raised' do
          args[:platform] = 'Windows Phone'
          create_device_request
          expect(error_code).to eq('VALIDATION_ERROR')
        end
      end

      context 'with no auth' do
        it 'AuthenticationError is raised' do
          post '/graphql', params: { query: create_device_mutation(**args) }
          expect(error_code).to eq('AUTHENTICATION_ERROR')
        end
      end
    end
  end
end

def create_device_mutation(**args)
  <<~GQL
    mutation {
    createDevice(token: "#{args[:token]}", platform: "#{args[:platform]}",
                 clientIdentifier: "#{args[:client_identifier]}") {
        device {
          id
          token
          platform
          clientIdentifier
          user {
            id
            name
          }
        }
      }
    }
  GQL
end
