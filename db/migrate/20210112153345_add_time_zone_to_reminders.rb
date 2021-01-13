class AddTimeZoneToReminders < ActiveRecord::Migration[6.1]
  def change
    add_column :reminders, :time_zone, :string, null: false
  end
end
