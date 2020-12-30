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
  scope :inactive, -> { where(active: false) }
  scope :with_certain_days, ->(certain_days) { where('frequency && ARRAY[?]', certain_days) }

  def logged?(selected_date)
    habit_logs.where(logged_date: selected_date).exists?
  end

  def longest_streak
    LONGEST_STREAK_QUERY

    sql = ActiveRecord::Base.sanitize_sql_array([LONGEST_STREAK_QUERY, id])

    ActiveRecord::Base.connection.execute(sql).first
  end

  def current_streak(selected_date)
    CURRENT_STREAK_QUERY

    sql = ActiveRecord::Base.sanitize_sql_array([CURRENT_STREAK_QUERY, id, selected_date, selected_date])

    ActiveRecord::Base.connection.execute(sql).first
  end

  private

  def frequency_is_valid
    return unless frequency

    valid_options = %w[daily monday tuesday wednesday thursday friday saturday sunday]

    return unless !frequency.is_a?(Array) || frequency.any? { |option| valid_options.exclude?(option) }

    errors.add(:frequency, "Must be one of: #{valid_options}")
  end

  LONGEST_STREAK_QUERY = <<-SQL
                  WITH distinct_dates AS (
                    SELECT DISTINCT 
                      logged_date
                    FROM habit_logs
                    WHERE habit_id = '?'
                    ORDER BY logged_date DESC
                  ),
                  groups AS (
                  SELECT
                    ROW_NUMBER() OVER (ORDER BY logged_date) AS rank_number,
                    (logged_date - INTERVAL '1 day' *  ROW_NUMBER() OVER (ORDER BY logged_date)) AS grp,
                    logged_date
                  FROM distinct_dates
                )
                SELECT
                  COUNT(*) AS habit_streak,
                  MIN(logged_date) AS start_date,
                  MAX(logged_date) AS end_date
                FROM groups
                GROUP BY grp
                ORDER BY habit_streak DESC, start_date DESC
                LIMIT 1;
  SQL

  CURRENT_STREAK_QUERY = <<-SQL
                  WITH distinct_dates AS (
                    SELECT DISTINCT
                      logged_date
                    FROM habit_logs
                    WHERE habit_id = '?' AND logged_date <= ?
                    ORDER BY logged_date DESC
                  ),
                  groups AS (
                  SELECT
                    ROW_NUMBER() OVER (ORDER BY logged_date) AS rank_number,
                    (logged_date - INTERVAL '1 day' *  ROW_NUMBER() OVER (ORDER BY logged_date)) AS grp,
                    logged_date
                  FROM distinct_dates
                )
                SELECT
                  COUNT(*) AS habit_streak,
                  MIN(logged_date) AS start_date,
                  MAX(logged_date) AS end_date
                FROM groups
                GROUP BY grp
                HAVING MAX(logged_date) = ?
                ORDER BY end_date DESC
                LIMIT 1;
  SQL
end
