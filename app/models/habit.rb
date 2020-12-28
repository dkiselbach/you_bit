# frozen_string_literal: true

# Habit model
class Habit < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :habit_type, presence: true, inclusion: { in: %w[goal limit], message: "Must be either 'goal' or 'limit'" }
  validates :active, inclusion: { in: [true, false] }
  validates :start_date, presence: true
  validate :start_date_is_valid_datetime
  validate :frequency_is_valid
  belongs_to :user
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false ) }
  scope :with_certain_days, ->(certain_days) { where('frequency && ARRAY[?]', certain_days) }

  private

  def start_date_is_valid_datetime
    Date.parse(start_date.to_s)
  rescue
    errors.add(:start_date, 'must be a valid date')
  end

  def frequency_is_valid
    return unless frequency

    valid_options = %w[daily monday tuesday wednesday thursday friday saturday sunday]

    return unless !frequency.is_a?(Array) || frequency.any? { |option| valid_options.exclude?(option) }

    errors.add(:frequency, "Must be one of: #{valid_options}")
  end
end
