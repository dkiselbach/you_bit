class ChangeFrequencyFormatInHabits < ActiveRecord::Migration[6.1]
  def change
    execute "alter table habits
                    alter frequency drop default,
                    alter frequency type text[] using array[frequency],
                    alter frequency set default '{daily}';"
  end
end
