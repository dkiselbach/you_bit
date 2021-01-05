# frozen_string_literal: true

module Mutations
  # Destroys a habit for a user.
  class DestroyHabit < BaseMutation
    description 'Deletes a Habit for a user.'

    field :habit, Types::HabitType, null: false, description: 'The information for the habit you deleted.'
    argument :habit_id, ID, required: true, description: 'The ID of the Habit.'

    def resolve(habit_id:)
      habit = find_habit_in_user_context(habit_id: habit_id)

      habit.destroy

      { habit: habit }
    end
  end
end
