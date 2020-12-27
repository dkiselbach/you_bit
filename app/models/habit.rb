class Habit < ApplicationRecord
  frequency_options = %w[daily week-days week-ends monday tuesday wednesday thursday friday saturday sunday]
  validates :name, presence: true, length: { maximum: 50 }
  validates :habit_type, presence: true, inclusion: { in: %w[goal limit], message: "Must be either 'goal' or 'limit'" }
  validates :frequency, presence: true, inclusion: { in: frequency_options,
                                                     message: "Must be one of: #{frequency_options}" }
  validates :start_date, presence: true
  validate :start_date_is_valid_datetime
  belongs_to :user

  private

  def start_date_is_valid_datetime
    Date.parse(start_date.to_s)
  rescue
    errors.add(:start_date, 'must be a valid date')
  end
end
