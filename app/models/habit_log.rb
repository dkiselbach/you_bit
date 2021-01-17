# frozen_string_literal: true

class HabitLog < ApplicationRecord
  validates :habit_type, habit_type: true, presence: true
  validates :logged_date, date: true, presence: true
  belongs_to :habit
  scope :most_recent, -> { order('logged_date DESC').first }
end
