# frozen_string_literal: true

module Mutations
  # Destroys a Device for a user.
  class DestroyDevice < BaseMutation
    description 'Deletes a Device for a user.'

    field :device, Types::DeviceType, null: false, description: 'The information for the Device you deleted.'
    argument :token, String, required: true, description: 'The Token of the Device.'

    def resolve(token:)
      device = Device.find_by(token: token)

      if device.nil?
        raise Errors::UserInputError.new('Device not found.',
                                         errors: I18n.t('graphql_devise.errors.bad_token'))
      end

      find_object_in_user_context(object: device, klass: Device)

      device.destroy

      { device: device }
    end
  end
end
