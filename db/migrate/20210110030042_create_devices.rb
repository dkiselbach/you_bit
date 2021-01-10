class CreateDevices < ActiveRecord::Migration[6.1]
  def change
    create_table :devices do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.string :platform
      t.string :client_identifier

      t.timestamps
    end
  end
end
