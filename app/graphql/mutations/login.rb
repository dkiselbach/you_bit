# frozen_string_literal: true

module Mutations
  # Class responsible for logging in the user. This is a child class of the graphql devise gem.
  class Login < Mutations::BaseMutation
    description "Login a user with email and password. This will return the user object and the associated
 credentials for login."
    argument :email, String, required: true
    argument :password, String, required: true

    field :user, Types::UserType, null: false, description: "Access the user's fields if login is successful."
    field :credentials,
          Types::UserCredentialType,
          null: false,
          description: 'Authentication credentials for the user. Null if after signUp resource is not active for
 authentication (e.g. Email confirmation required).'

    def resolve(email:, password:)
      resource = find_resource(
        :email,
        get_case_insensitive_field(:email, email)
      )

      invalid_email unless resource

      invalid_password unless resource.valid_password?(password)

      new_headers = set_auth_headers(resource)
      controller.sign_in(:user, resource, store: false, bypass: false)

      { user: resource, credentials: new_headers }
    end

    private

    def invalid_email
      raise_user_error_list(
        I18n.t('graphql_devise.sessions.bad_email'),
        errors: I18n.t('graphql_devise.errors.bad_email')
      )
    end

    def invalid_password
      raise_user_error_list(
        I18n.t('graphql_devise.sessions.bad_password'),
        errors: I18n.t('graphql_devise.errors.bad_password')
      )
    end
  end
end
