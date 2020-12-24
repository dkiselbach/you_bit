# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false, description: 'The unique identifier for the user.'
    field :name, String, null: false, description: 'The Name of the user.'
    field :email, String, null: false, description: 'The Email of the user.'
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: 'The DateTime value of when the user was created.'
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false, description: ' The DateTime value of when the user was updated.'
    field :provider, String, null: false, description: 'The authentication Provider used.'
  end
end
