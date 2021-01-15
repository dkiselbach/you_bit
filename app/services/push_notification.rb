# Class for sending push notifications to the RN App.
class PushNotification
  attr_reader :token, :sound, :body, :title, :handler, :client, :verified

  def initialize(token:, habit_name:, **args)
    raise ArgumentError, 'Token cannot be nil' if token.nil?
    raise ArgumentError, 'Habit Name cannot be nil' if habit_name.nil?

    @client = Exponent::Push::Client.new
    @token = token
    @title = habit_name
    @sound = args[:sound] || default_sound
    @body = args[:body] || default_message
  end

  def send
    message = [{
                 to: token,
                 sound: sound,
                 title: title,
                 body: body
               }]

    self.handler = client.send_messages(message)
  end

  def verify_delivery
    self.verified = client.verify_deliveries(handler.receipt_ids)
  end

  private

  def default_sound
    'default'
  end

  def default_message
    'Do the Habit!'
  end

  def handler=(client_response)
    @handler = client_response
    return unless client_response.errors?

    parsed_response = JSON.parse(client_response.response.response_body)
    error_type = parsed_response.dig('data', 0, 'details', 'error')
    error_message = parsed_response.dig('data', 0, 'message')
    raise DeviceNotRegistered, error_message if error_type == 'DeviceNotRegistered'

    raise StandardError, error_message
  end

  def verified=(verification_response)
    @verified == true unless

  end

end

# Error class for when the device token is invalid
class DeviceNotRegistered < StandardError
  def initialize(message)
    super
  end
end
