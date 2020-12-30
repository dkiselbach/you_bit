class CreateHabitLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :habit_logs do |t|
      t.references :habit, null: false, foreign_key: true
      t.date :logged_date, null: false
      t.string :habit_type, null: false

      t.timestamps
    end
  end
end
