# frozen_string_literal: true

# A class for the Reminder model.
class Reminder < ApplicationRecord
  validates :remind_at, date: true, presence: true
  validates :time_zone, time_zone: true, presence: true
  belongs_to :habit
  after_save :set_reminder
  attr_accessor :scheduler

  DAYS_OF_WEEK = %w[sunday monday tuesday wednesday thursday friday saturday].freeze

  def self.schedule_all
    Reminder.all.find_each(&:enqueue_reminders)
  end

  def set_reminder
    enqueue_reminders(scheduler: 'new_reminder')
  end

  private

  def enqueue_reminders(scheduler: 'daily_scheduler')
    self.scheduler = scheduler
    return unless habit.active && (habit.daily? || habit.frequency.include?(weekday))

    remind_at = reminder_time
    return if remind_at.nil?

    habit.user.devices.each do |device|
      PushNotificationJob.set(wait_until: remind_at).perform_later(self, device)
    end
  end

  def reminder_time
    # scheduler is set for everyday at 12:00 AM UTC. Use UTC for the date unless the method was
    # called from a new reminder being created.
    date = scheduler == 'daily_scheduler' ? Time.now.in_time_zone('UTC') : Time.now.in_time_zone(time_zone)
    Time.zone = time_zone
    time = remind_at.in_time_zone
    reminder_time = Time.zone.local(date.year, date.month, date.day, time.hour, time.min, time.sec)
    reminder_time > Time.current ? reminder_time : nil
  end

  def weekday
    scheduler == 'daily_scheduler' ? DAYS_OF_WEEK[Time.now.in_time_zone('UTC').wday] : DAYS_OF_WEEK[Time.now.in_time_zone(time_zone).wday]
  end
end
