# frozen_string_literal: true

# A class for the Reminder model.
class Reminder < ApplicationRecord
  validates :remind_at, date: true, presence: true
  validates :time_zone, time_zone: true, presence: true
  belongs_to :habit
  # after_save :enqueue_reminders

  def enqueue_reminders
    return unless habit.active

    # Reminder.first.remind_at.next_week(:monday)

    # If Daily, enqueue 7 reminders for the next 7 days. If not daily, enqueue each day of the week.
    # Enqueued Job will enqueue another job the next week. Ensuring notifications are enqueued
    # In perpetuity
  end
end
