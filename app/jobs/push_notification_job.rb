# frozen_string_literal: true

# Job for sending push notifications to the user's device.
class PushNotificationJob < ApplicationJob
  def perform(reminder, device)
    return unless Reminder.find_by(id: reminder.id) && Device.find_by(id: device.id)

    PushNotification.new(token: device.token, habit_name: reminder.habit.name).send

    PushNotificationJob.set(wait_until: reminder.next_reminder(days: 7)).perform_later(reminder, device)
  rescue ExpoPushNotificationError => e
    device.update(last_error: { error_type: e.class.to_s, error_message: e.message }.to_json)
  rescue DeviceNotRegistered
    device.destroy
  end
end
