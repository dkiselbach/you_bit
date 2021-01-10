# frozen_string_literal: true

module Mutations
  # Destroys a habit log for a user.
  class DestroyHabitLog < BaseMutation
    description 'Deletes a Habit Log for a user.'

    field :habit_log, Types::HabitLogType, null: false, description: 'The information for the habit log you deleted.'
    argument :habit_log_id, ID, required: true, description: 'The ID of the Habit Log.'

    def resolve(habit_log_id:)
      habit_log = HabitLog.find(habit_log_id)

      find_object_in_user_context(object_id: habit_log.habit_id, klass: Habit)

      habit_log.destroy

      { habit_log: habit_log }
    end
  end
end
