# frozen_string_literal: true

class AddCurrentStreakToHabitLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :habit_logs, :current_streak, :integer
  end
end
