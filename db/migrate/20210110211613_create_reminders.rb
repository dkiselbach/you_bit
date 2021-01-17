# frozen_string_literal: true

class CreateReminders < ActiveRecord::Migration[6.1]
  def change
    create_table :reminders do |t|
      t.references :habit, null: false, foreign_key: true
      t.datetime :remind_at, null: false

      t.timestamps
    end
  end
end
