# frozen_string_literal: true

# A class for the Reminder model.
class Reminder < ApplicationRecord
  validates :remind_at, date: true, presence: true
  validates :time_zone, time_zone: true, presence: true
  belongs_to :habit
  after_save :enqueue_reminders

  def enqueue_reminders
    return unless habit.active

    Time.zone = time_zone

    habit.user.devices.each do |device|
      if habit.frequency == ['daily']
        first_reminder = next_reminder(days: 0)
        first_reminder_time = first_reminder || next_reminder
        PushNotificationJob.set(wait_until: first_reminder_time).perform_later(self, device)
        (1..6).each do |day|
          PushNotificationJob.set(wait_until: next_reminder(days: day)).perform_later(self, device)
        end
      else
        habit.frequency.each do |day|
          date = remind_at.in_time_zone.next_week(day.to_sym)
          time = remind_at.in_time_zone
          reminder_time = Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)

          PushNotificationJob.set(wait_until: reminder_time).perform_later(self, device)
        end
      end
    end

    # Reminder.first.remind_at.next_week(:monday)

    # If Daily, enqueue 7 reminders for the next 7 days. If not daily, enqueue each day of the week.
    # Enqueued Job will enqueue another job the next week. Ensuring notifications are enqueued
    # In perpetuity
  end

  def next_reminder(days: 7)
    Time.zone = time_zone
    date = Time.current + days.days
    time = remind_at.in_time_zone
    reminder_time = Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
    reminder_time > Time.current ? reminder_time : nil
  end
end
