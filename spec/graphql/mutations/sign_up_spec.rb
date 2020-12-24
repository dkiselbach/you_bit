# frozen_string_literal: true

require 'rails_helper'

module Mutations
  RSpec.describe SignUp, type: :request do
    describe '.resolve' do
      it 'creates a user with valid name field' do
        name = Faker::Name.name
        email = Faker::Internet.email
        password = Faker::Internet.password

        expect do
          post '/graphql', params: { query: mutation(name, email, password) }
        end.to change { User.count }.by(1)

        access_token = JSON.parse(response.body).dig('data', 'userSignUp', 'credentials', 'accessToken')

        expect(access_token).to be
        expect(User.find_by(email: email).name).to eq(name)
      end

      it 'returns user type in addition to credentials' do
        name = Faker::Name.name
        email = Faker::Internet.email
        password = Faker::Internet.password

        post '/graphql', params: { query: mutation(name, email, password) }

        response_json = JSON.parse(response.body).dig('data', 'userSignUp', 'user')

        user_id, user_name, user_email, created_at = response_json.values_at('id', 'name', 'email', 'createdAt')

        expect(user_id).not_to be_nil
        expect({ name: user_name, email: user_email }).to eq({ name: name, email: email })
        expect { DateTime.parse(created_at) }.not_to raise_exception
      end

      it 'returns an error if email is already taken' do
        name = Faker::Name.name
        email = Faker::Internet.email
        password = Faker::Internet.password

        2.times do
          post '/graphql', params: { query: mutation(name, email, password) }
        end

        error_message = JSON.parse(response.body).dig('errors')[0].dig('extensions', 'detailed_errors')[0]

        expect(error_message).to eq('Email has already been taken')
      end
    end
  end
end

def mutation(name, email, password)
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
