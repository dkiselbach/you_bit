# frozen_string_literal: true

module Mutations
  # Creates a device for a user to be used for push notifications.
  class CreateDevice < BaseMutation
    description 'Creates a device for a user to be used for push notifications.'

    field :device, Types::DeviceType, null: false, description: 'The information for the Device you created.'

    argument :token, String, required: true,
                             description: 'The Expo Push Token.
This will be used when sending push notifications to the user device.'
    argument :platform, String, required: true,
                                description: "The Platform the device is on. This is one of: 'iOS', 'Android' or 'Web'."
    argument :client_identifier, String, required: false,
                                         description: 'The name of the device.'

    def resolve(**attrs)
      device = current_resource.devices.create(attrs)

      return { device: device } if device.valid?

      raise Errors::ValidationError.new("Device couldn't be created",
                                        errors: device.errors.messages)
    end
  end
end
