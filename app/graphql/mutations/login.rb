# frozen_string_literal: true

module Mutations
  # Class responsible for logging in the user. This is a child class of the graphql devise gem.
  class Login < GraphqlDevise::Mutations::Login
    description "Login a user with email and password. This will return the user object and the associated
 credentials for login."
    field :user, Types::UserType, null: true, description: "Access the user's fields if login is successful."

    def resolve(**args)
      user_resource = super

      user_resource.merge(user: user_resource[:authenticatable])
    end
  end
end
