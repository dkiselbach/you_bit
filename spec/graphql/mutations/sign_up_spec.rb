# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe SignUp, type: :request do
    describe '.resolve' do
      before do
        @name = Faker::Name.name
        @email = Faker::Internet.email
        @password = Faker::Internet.password

        post '/graphql', params: { query: sign_up_mutation(@name, @email, @password) }
        @response_body = JSON.parse(response.body).dig('data', 'userSignUp')
      end

      it 'creates a user' do
        expect(User.find_by(email: @email).name).to eq(@name)
      end

      it 'returns authentication token' do
        access_token = @response_body.dig('credentials', 'accessToken')
        expect(access_token).not_to be_nil
      end

      it 'returns user type' do
        user_name, user_email = @response_body.dig('user').values_at('name', 'email')

        expect({ name: user_name, email: user_email }).to eq({ name: @name, email: @email })
      end

      it 'returns an error if email is already taken' do
        post '/graphql', params: { query: sign_up_mutation(@name, @email, @password) }

        error_message = JSON.parse(response.body).dig('errors')[0].dig('extensions', 'detailed_errors')[0]

        expect(error_message).to eq('Email has already been taken')
      end
    end
  end
end

def sign_up_mutation(name, email, password)
  <<~GQL
    mutation {
      userSignUp(name: "#{name}", email: "#{email}",
        password: "#{password}", passwordConfirmation: "#{password}") {
          credentials {
            accessToken
            tokenType
          }
          user {
            id
            name
            email
            createdAt
          }
        }
    }
  GQL
end
