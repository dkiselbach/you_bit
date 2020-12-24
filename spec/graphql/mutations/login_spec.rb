# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe Login, type: :request do
    describe '.resolve' do
      before do
        @email = Faker::Internet.email
        @password = Faker::Internet.password
        create(:user, email: @email, password: @password)
        post '/graphql', params: { query: sign_in_mutation(@email, @password) }
        @response_body = JSON.parse(response.body).dig('data', 'userLogin')
      end

      it 'logs in a user' do
        access_token = @response_body.dig('credentials', 'accessToken')
        expect(access_token).not_to be_nil
      end

      it 'returns user type' do
        user_email = @response_body.dig('user', 'email')

        expect(user_email).to eq(@email)
      end

    end
  end
end

def sign_in_mutation(email, password)
  <<~GQL
      mutation {
        userLogin(email: "#{email}", password: "#{password}") {
          credentials {
            accessToken
            client
            uid
          }
        user {
          id
          email
          name
          createdAt
          updatedAt
        }
      }
    }
  GQL
end
