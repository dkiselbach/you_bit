class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false, limit: 100
      t.index :name, unique: true
      t.timestamps

    end

    add_reference :habits, :category, foreign_key: true
    add_column :habits, :category_name, :string
  end
end
