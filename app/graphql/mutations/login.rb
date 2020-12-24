# frozen_string_literal: true

module Mutations
  class Login < GraphqlDevise::Mutations::Login
    field :user, Types::UserType, null: true, description: "Access the user's fields if login is successful."

    def resolve(**attrs)
      user_resource = super

      user_resource.merge(user: user_resource[:authenticatable])
    end
  end
end
