class CreateHabits < ActiveRecord::Migration[6.1]
  def change
    create_table :habits do |t|
      t.string :name, null: false, limit: 50
      t.string :description
      t.string :habit_type, null: false, default: 'goal'
      t.string :frequency, null: false, default: 'daily'
      t.date :start_date, null: false

      t.timestamps
    end
  end
end
