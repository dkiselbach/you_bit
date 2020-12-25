# frozen_string_literal: true

require 'rails_helper'

module Resolvers
  RSpec.describe CheckPasswordToken, type: :request do
    describe '.resolve' do
      before do
        @email = Faker::Internet.email
        @user = create(:user, email: @email)
        @token = @user.send_reset_password_instructions(email: @email, provider: 'email',
                                                        redirect_url: nil, template_path: ['user_mailer'])
      end

      it 'returns credentials' do
        post '/graphql', params: { query: check_password_token_query(@token) }
        access_token = JSON.parse(response.body).dig('data', 'userCheckPasswordToken', 'accessToken')
        expect(access_token).to be_a(String)
      end

      it 'returns user object' do
        post '/graphql', params: { query: check_password_token_query(@token) }
        email = JSON.parse(response.body).dig('data', 'userCheckPasswordToken', 'user', 'email')
        expect(email).to eq(@email)
      end

      it 'returns an error if token is expired' do
        Timecop.travel(7.hours) do
          post '/graphql', params: { query: check_password_token_query(@token) }
          error_message = JSON.parse(response.body).dig('errors', 0, 'message')
          expect(error_message).to eq('Reset password token is no longer valid.')
        end
      end

      it 'returns an error if token is invalid' do
        post '/graphql', params: { query: check_password_token_query('Invalid Token') }
        error_message = JSON.parse(response.body).dig('errors', 0, 'message')
        expect(error_message).to eq('No user found for the specified reset token.')
      end
    end
  end
end

def check_password_token_query(token)
  <<~GQL
    query {
      userCheckPasswordToken(resetPasswordToken: "#{token}") {
        accessToken
        client
        expiry
        tokenType
        uid
        user {
          name
          email
          provider
          createdAt
        }
      }
    }
  GQL
end
