# frozen_string_literal: true

module Mutations
  # Destroys a habit for a user.
  class DestroyHabit < BaseMutation
    description 'Deletes a Habit for a user.'

    field :habit, Types::HabitType, null: false, description: 'The information for the habit you deleted.'
    argument :habit_id, ID, required: true, description: 'The ID of the Habit.'

    def resolve(habit_id:)
      habit = find_object_in_user_context(object_id: habit_id, klass: Habit)

      habit.destroy

      { habit: habit }
    end
  end
end
