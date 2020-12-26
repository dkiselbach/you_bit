# frozen_string_literal: true

module Resolvers
  # This class will check if a password reset token is valid. If so it will authorize for the users credentials.
  # These credentials can then be used in a subsequent request to update the password.
  # Note that once the password is updated that this token will be invalidated.
  class CheckPasswordToken < BaseResolver
    description "This resolver will check if a password reset token is valid. If so it will authorize for the users
                               credentials. These credentials can then be used in a subsequent request to update the
                               password. Note that once the password is updated this token is invalidated."
    type Types::UserCredentialType, null: false
    argument :reset_password_token, String, required: true, description: 'The reset password token emailed to the user.'

    def resolve(reset_password_token:)
      resource = resource_class.with_reset_password_token(reset_password_token)
      raise_user_error(I18n.t('graphql_devise.passwords.reset_token_not_found')) if resource.blank?

      if resource.reset_password_period_valid?

        resource.save!

        set_auth_headers(resource) if resource.active_for_authentication?
      else
        raise_user_error(I18n.t('graphql_devise.passwords.reset_token_expired'))
      end
    end
  end
end