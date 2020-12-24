# frozen_string_literal: true

module Mutations
  class SignUp < BaseMutation
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password,              String, required: true
    argument :password_confirmation, String, required: true

    field :credentials,
          Types::UserCredentialType,
          null: true,
          description: 'Authentication credentials. Null if after signUp resource is not active for authentication (e.g. Email confirmation required).'

    field :user, Types::UserType, null: true, description: "Access the user's fields if sign up is successful."

    def resolve(**attrs)
      resource = build_resource(attrs.merge(provider: provider))
      raise_user_error(I18n.t('graphql_devise.resource_build_failed')) if resource.blank?

      if resource.save
        yield resource if block_given?

        response_payload = { authenticatable: resource }

        response_payload[:credentials] = set_auth_headers(resource) if resource.active_for_authentication?

        response_payload.merge(user: resource)
      else
        resource.try(:clean_up_passwords)
        raise_user_error_list(
          I18n.t('graphql_devise.registration_failed'),
          errors: resource.errors.full_messages
        )
      end
    end

    private

    def build_resource(attrs)
      resource_class.new(attrs)
    end
  end
end
