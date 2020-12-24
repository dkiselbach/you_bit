# frozen_string_literal: true

module Mutations
  # This class is a resolver that will send a password reset token to the user if their email is valid.
  class SendPasswordReset < BaseMutation
    description "Send a password reset token to the user's email if the email is associated with a valid user."
    argument :email, String, required: true, description: 'Email of the user you are resetting the password for.'

    field :message, String, null: false, description: 'Message indicating the result of the password reset request.'

    def resolve(email:)
      user = find_resource(:email, get_case_insensitive_field(:email, email))

      raise_user_error(I18n.t('graphql_devise.user_not_found')) unless user

      user.send_reset_password_instructions(email: email, provider: 'email', redirect_url: nil,
                                            template_path: ['user_mailer'],
                                            schema_url: controller.full_url_without_params)

      raise_user_error_list(I18n.t('graphql_devise.invalid_resource'), errors: user.errors.full_messages) if user.errors

      { message: I18n.t('graphql_devise.passwords.send_instructions') }
    end
  end
end
