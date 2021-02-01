# frozen_string_literal: true

# A class for the Reminder model.
class Reminder < ApplicationRecord
  validates :remind_at, date: true, presence: true
  validates :time_zone, time_zone: true, presence: true
  belongs_to :habit
  after_save :enqueue_reminders

  DAYS_OF_WEEK = %w[sunday monday tuesday wednesday thursday friday saturday].freeze

  def enqueue_reminders
    return unless habit.active && (habit.frequency == ['daily'] || habit.frequency.include?(weekday))

    remind_at = reminder_time
    return if remind_at.nil?

    habit.user.devices.each do |device|
      PushNotificationJob.set(wait_until: remind_at).perform_later(self, device)
    end
  end

  private

  def reminder_time
    Time.zone = time_zone
    date = Time.now.utc
    time = remind_at.in_time_zone
    reminder_time = Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
    reminder_time > Time.current ? reminder_time : nil
  end

  def weekday
    DAYS_OF_WEEK[Time.now.utc.wday]
  end
end
