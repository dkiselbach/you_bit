# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false, description: 'The Unique Identifier for the User.'
    field :name, String, null: false, description: 'The Name of the User.'
    field :email, String, null: false, description: 'The Email of the User.'
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the User was created.'
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: ' The DateTime value of when the User was updated.'
    field :provider, String, null: false, description: 'The authentication Provider used.'
  end
end
