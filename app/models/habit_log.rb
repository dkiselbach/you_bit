# frozen_string_literal: true

class HabitLog < ApplicationRecord
  validates :habit_type, habit_type: true, presence: true
  validates :logged_date, date: true, presence: true
  belongs_to :habit
  scope :most_recent, -> { order('logged_date DESC').first }
  scope :longest_streak, -> { order('current_streak DESC').first }
  before_validation :update_current_streak

  private

  DAYS_OF_WEEK = %w[sunday monday tuesday wednesday thursday friday saturday].freeze

  def update_current_streak
    return if habit_type == 'limit'

    last_log = HabitLog.where(habit_id: habit_id).most_recent

    if last_log.blank?
      self.current_streak = 1
      return
    end

    return if habit.daily? && (logged_date - last_log.logged_date).to_i != 1

    return if !habit.daily? && last_log.logged_date != last_log_date

    self.current_streak = last_log.current_streak + 1
  end

  def last_log_date
    frequency = habit.frequency
    current_frequency_idx = frequency.index(weekday)
    if current_frequency_idx.zero?
      logged_date - (7 - DAYS_OF_WEEK.index(frequency.last) + logged_date.wday)
    else
      logged_date - (logged_date.wday - DAYS_OF_WEEK.index(frequency[current_frequency_idx - 1]))
    end
  end

  def weekday
    DAYS_OF_WEEK[logged_date.wday]
  end
end
