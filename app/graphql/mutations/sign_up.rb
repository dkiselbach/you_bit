# frozen_string_literal: true

module Mutations
  # Class responsible for handling user sign up. The resolver method will return the user object and the associated
  # credentials for login
  class SignUp < BaseMutation
    description 'Sign up a user with name and email. This will will return the
user object and the associated credentials for login.'
    argument :name, String, required: true, description: 'Name of the user'
    argument :email, String, required: true, description: 'Email of the user.
This email will need to be valid to receive reset password emails'
    argument :password, String, required: true, description: 'Password for the user.'
    argument :password_confirmation, String, required: true, description: 'Password confirmation that must match the
password.'

    field :credentials,
          Types::UserCredentialType,
          null: true,
          description: 'Authentication credentials for the user. Null if after signUp resource is not active for
 authentication (e.g. Email confirmation required).'

    field :user, Types::UserType, null: true, description: 'The newly signed up user fields.'

    def resolve(**attrs)
      user = build_resource(attrs.merge(provider: provider))
      raise_user_error(I18n.t('graphql_devise.resource_build_failed')) if user.blank?

      if user.save
        return { user: user, credentials: user.active_for_authentication? ? set_auth_headers(user) : nil }
      end

      user.try(:clean_up_passwords)
      raise_user_error_list(
        I18n.t('graphql_devise.registration_failed'),
        errors: user.errors.full_messages
      )
    end

    private

    def build_resource(attrs)
      resource_class.new(attrs)
    end
  end
end
