# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe SendPasswordReset, type: :request do
    describe '.resolve' do
      before do
        @email = Faker::Internet.email
        create(:user, email: @email)
      end

      it 'queues a password reset email' do
        expect { post '/graphql', params: { query: send_password_mutation(@email) } }
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'returns password reset message' do
        message = 'You will receive an email with instructions on how to reset your password in a few minutes.'
        post '/graphql', params: { query: send_password_mutation(@email) }
        message = JSON.parse(response.body).dig('data', 'userSendPasswordReset', 'message')
        expect(message).to eq(message)
      end

      it 'returns an error if email is invalid' do
        post '/graphql', params: { query: send_password_mutation('invalid@example.com') }

        error_message = JSON.parse(response.body).dig('errors')[0].dig('message')

        expect(error_message).to eq('User was not found or was not logged in.')
      end
    end
  end
end

def send_password_mutation(email)
  <<~GQL
    mutation {
      userSendPasswordReset(email: "#{email}") {
        message
      }
    }
  GQL
end
