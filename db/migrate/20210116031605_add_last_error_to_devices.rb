# frozen_string_literal: true

class AddLastErrorToDevices < ActiveRecord::Migration[6.1]
  def change
    add_column :devices, :last_error, :jsonb
  end
end
