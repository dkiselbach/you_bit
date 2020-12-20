# frozen_string_literal: true

module Mutations
  class SignUp < GraphqlDevise::Mutations::SignUp
    argument :name, String, required: true

    field :user, Types::UserType, null: true

    def resolve(email:, **attrs)
      super
    end
  end
end
