class AddActiveToHabits < ActiveRecord::Migration[6.1]
  def change
    add_column :habits, :active, :boolean, null: false, default: true
  end
end
