module Services
  # Class for sending push notifications to the RN App.
  class PushNotification
    attr_accessor :handler
    attr_reader :client, :token, :sound, :body, :title

    def initialize(**args)
      @client = Exponent::Push::Client.new
      @token = "ExponentPushToken[#{args[:token]}]"
      @title = args[:habit_name]
      @sound = 'default'
      @body = args[:body]
    end

    def send
      message = {
        to: token,
        sound: sound,
        title: title,
        body: body
      }

      self.handler = client.send_messages(message)
    end

    def verify_delivery
      client.verify_deliveries(handler.receipt_ids)
    end
  end
end
