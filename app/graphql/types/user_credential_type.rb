# frozen_string_literal: true

module Types
  class UserCredentialType < GraphqlDevise::Types::CredentialType
    field :user, Types::UserType, null: true, method: :uid

    def user
      User.find_by(email: uid)
    end
  end
end
