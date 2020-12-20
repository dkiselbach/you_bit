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
        }
    }
  GQL
end
