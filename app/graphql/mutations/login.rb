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

      if resource && active_for_authentication?(resource)
        if invalid_for_authentication?(resource, password)
          raise_user_error_list(
            I18n.t('graphql_devise.sessions.bad_password'),
            errors: I18n.t('graphql_devise.errors.bad_password')
          )
        end

        new_headers = set_auth_headers(resource)
        controller.sign_in(:user, resource, store: false, bypass: false)

        yield resource if block_given?

        { user: resource, credentials: new_headers }
      elsif resource && !active_for_authentication?(resource)
        if locked?(resource)
          raise_user_error(I18n.t('graphql_devise.mailer.unlock_instructions.account_lock_msg'))
        else
          raise_user_error(I18n.t('graphql_devise.sessions.not_confirmed', email: resource.email))
        end
      else
        raise_user_error_list(
          I18n.t('graphql_devise.sessions.bad_email'),
          errors: I18n.t('graphql_devise.errors.bad_email')
        )
      end
    end

    private

    def invalid_for_authentication?(resource, password)
      valid_password = resource.valid_password?(password)

      (resource.respond_to?(:valid_for_authentication?) && !resource.valid_for_authentication? { valid_password }) ||
        !valid_password
    end

    def active_for_authentication?(resource)
      !resource.respond_to?(:active_for_authentication?) || resource.active_for_authentication?
    end

    def locked?(resource)
      resource.respond_to?(:locked_at) && resource.locked_at
    end
  end
end
