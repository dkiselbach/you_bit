# frozen_string_literal: true

# Job for sending push notifications to the user's device.
class PushNotificationJob < ApplicationJob
  before_perform :validate_reminder
  discard_on ArgumentError, ActiveRecord::RecordNotFound
  sidekiq_options retry: false

  def perform(reminder, device)
    PushNotification.new(token: device.token, habit_name: reminder.habit.name).send
  rescue ExpoPushNotificationError => e
    device.update(last_error: { error_type: e.class.to_s, error_message: e.message }.to_json)
  rescue DeviceNotRegistered
    device.destroy
  end

  private

  def validate_reminder
    reminder = Reminder.find(arguments.first.id)
    Device.find(arguments.second.id)

    return if reminder.habit.active? && !reminder.habit.logged?(selected_date: Date.current)

    raise ArgumentError
  end
end

