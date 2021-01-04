# frozen_string_literal: true

module Mutations
  # Destroys a habit for a user.
  class DestroyHabit < BaseMutation
    description 'Deletes a Habit for a user.'

    field :habit, Types::HabitType, null: false, description: 'The information for the habit you deleted.'
    argument :habit_id, ID, required: true, description: 'The ID of the Habit.'

    def resolve(habit_id:)
      habit = Habit.find(habit_id)

      unless user_has_access_to_habit(habit: habit)
        raise Errors::ForbiddenError.new('User does not have access to the Habit',
                                         errors: I18n.t('graphql_devise.errors.bad_id'))
      end

      habit.destroy

      { habit: habit }
    end
  end
end
