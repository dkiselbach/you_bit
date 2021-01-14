# frozen_string_literal: true

# Habit model
class Habit < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :habit_type, presence: true, habit_type: true
  validates :active, inclusion: { in: [true, false] }
  validates :start_date, date: true, presence: true
  validates :category_name, presence: true, length: { maximum: 100 }
  validate :frequency_is_valid
  belongs_to :user
  belongs_to :category
  has_many :habit_logs, dependent: :destroy
  has_many :reminders, dependent: :destroy
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :with_certain_days, ->(certain_days) { where('frequency && ARRAY[?]', certain_days) }
  before_validation :check_category
  before_update :destroy_legacy_reminders

  def logged?(selected_date:)
    habit_logs.where(logged_date: selected_date).exists?
  end

  def logged(selected_date:)
    habit_log = habit_logs.find_by(logged_date: selected_date)
    { habit_log: habit_log, logged: habit_log.present? }
  end

  def longest_streak
    sql = ActiveRecord::Base.sanitize_sql_array([LONGEST_STREAK_QUERY, id]) if goal?

    sql = ActiveRecord::Base.sanitize_sql_array([LONGEST_LIMIT_STREAK_QUERY, start_date, Date.current, id]) if limit?

    ActiveRecord::Base.connection.execute(sql).first
  end

  def current_streak(selected_date:)
    sql = ActiveRecord::Base.sanitize_sql_array([CURRENT_STREAK_QUERY, id, selected_date, selected_date])

    ActiveRecord::Base.connection.execute(sql).first
  end

  def limit?
    habit_type == 'limit'
  end

  def goal?
    habit_type == 'goal'
  end

  private

  def check_category
    return false if category_name.nil?

    category_name.downcase!

    category = Category.find_by(name: category_name)

    category_id = if category.present?
                    category.id
                  else
                    Category.create(name: category_name).id
                  end

    self.category_id = category_id
  end

  def frequency_is_valid
    return unless frequency

    valid_options = %w[daily monday tuesday wednesday thursday friday saturday sunday]

    return unless !frequency.is_a?(Array) || frequency.any? { |option| valid_options.exclude?(option) }

    errors.add(:frequency, "Must be one of: #{valid_options}")
  end

  def destroy_legacy_reminders
    return unless frequency_changed?

    reminders.destroy_all
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

  LONGEST_LIMIT_STREAK_QUERY = <<-SQL
                  WITH distinct_dates AS (
                    SELECT
                      ?::DATE as logged_date
                    UNION ALL
                    SELECT
                      ?::DATE as logged_date
                    UNION ALL
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
                  MIN(logged_date) AS start_date,
                  MAX(logged_date) AS end_date,
                  CASE
                    WHEN logged_date - lag(logged_date) over (ORDER BY logged_date) IS NOT NULL THEN logged_date - lag(logged_date) over (ORDER BY logged_date)
                    ELSE 0
                  END AS habit_streak
                FROM groups
                GROUP BY grp, logged_date
                ORDER BY habit_streak DESC, start_date DESC
                LIMIT 1;
  SQL

  CURRENT_LIMIT_STREAK_QUERY = <<-SQL
                  WITH distinct_dates AS (
                    SELECT
                      '2020-10-01'::DATE as logged_date
                    UNION ALL
                    SELECT
                      '2021-01-12'::DATE as logged_date
                    UNION ALL
                    SELECT DISTINCT
                      logged_date
                    FROM habit_logs
                    WHERE habit_id = 4
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
                  MAX(logged_date) AS end_date,
                  CASE 
                    WHEN logged_date - lag(logged_date) over (ORDER BY logged_date) IS NOT NULL THEN logged_date - lag(logged_date) over (ORDER BY logged_date)
                    ELSE 0
                  END AS limit_streak
                FROM groups
                GROUP BY grp, logged_date
                ORDER BY start_date DESC
                LIMIT 1;
  SQL
end
