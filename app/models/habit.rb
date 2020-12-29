# frozen_string_literal: true

# Habit model
class Habit < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :habit_type, presence: true, habit_type: true
  validates :active, inclusion: { in: [true, false] }
  validates :start_date, date: true, presence: true
  validate :frequency_is_valid
  belongs_to :user
  has_many :habit_logs, dependent: :destroy
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false ) }
  scope :with_certain_days, ->(certain_days) { where('frequency && ARRAY[?]', certain_days) }

  private

  def frequency_is_valid
    return unless frequency

    valid_options = %w[daily monday tuesday wednesday thursday friday saturday sunday]

    return unless !frequency.is_a?(Array) || frequency.any? { |option| valid_options.exclude?(option) }

    errors.add(:frequency, "Must be one of: #{valid_options}")
  end
end
