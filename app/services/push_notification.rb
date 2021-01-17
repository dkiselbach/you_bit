# frozen_string_literal: true

# Class for sending push notifications to the RN App.
class PushNotification
  attr_accessor :handler, :verified, :error_type, :error_message, :parsed_response
  attr_reader :token, :sound, :body, :title, :client, :verified

  def initialize(token:, habit_name:, **args)
    raise ArgumentError, 'Token cannot be nil' if token.nil?
    raise ArgumentError, 'Habit Name cannot be nil' if habit_name.nil?

    @client = Exponent::Push::Client.new
    @token = token
    @title = habit_name
    @sound = args[:sound] || default_sound
    @body = args[:body] || default_body
  end

  def send
    self.handler = client.send_messages(message)
    return self unless handler.errors?

    parse_response
    raise DeviceNotRegistered, error_message if error_type == 'DeviceNotRegistered'

    raise ExpoPushNotificationError, error_message
  end

  def verify_delivery
    receipt_ids = handler.receipt_ids
    self.verified = client.verify_deliveries(receipt_ids)
    return self unless verified.errors?

    parse_response(index: receipt_ids.first, field: verified)
    raise DeviceNotRegistered, error_message if error_type == 'DeviceNotRegistered'

    raise ExpoPushNotificationError, error_message
  end

  private

  def default_sound
    'default'
  end

  def default_body
    'Do the Habit!'
  end

  def message
    [{
      to: token,
      sound: sound,
      title: title,
      body: body
    }]
  end

  def parse_response(index: 0, field: handler)
    parsed_response = JSON.parse(field.response.response_body)
    self.error_type = parsed_response.dig('data', index, 'details', 'error')
    self.error_message = parsed_response.dig('data', index, 'message')
  end
end

# Error class for when the device token is invalid
class DeviceNotRegistered < StandardError
end

# Error class for other expo errors
class ExpoPushNotificationError < StandardError
end
