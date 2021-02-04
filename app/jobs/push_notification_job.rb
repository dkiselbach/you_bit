# frozen_string_literal: true

# Job for sending push notifications to the user's device.
class PushNotificationJob < ApplicationJob
  sidekiq_options retry: false
  def perform(reminder, device)
    reminder = Reminder.find_by(id: reminder.id)
    device = Device.find_by(id: device.id)
    return unless reminder && device && reminder.habit.active?

    PushNotification.new(token: device.token, habit_name: reminder.habit.name).send
  rescue ExpoPushNotificationError => e
    device.update(last_error: { error_type: e.class.to_s, error_message: e.message }.to_json)
  rescue DeviceNotRegistered
    device.destroy
  end
end
