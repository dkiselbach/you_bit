# frozen_string_literal: true

module Types
  # Type definition for the Device model
  class DeviceType < Types::BaseObject
    field :id, ID, null: false, description: 'The Unique Identifier for the Device.'
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the Device was created'
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the Device was updated'
    field :token, String, null: false, description: 'The Expo Push Token.'
    field :platform, String, null: false, description: 'The Platform the device is on.'
    field :client_identifier, String, null: true, description: 'The name of the device.'
    field :user, Types::UserType, null: false, description: 'The User the device belongs to.'
  end
end
