# frozen_string_literal: true

module Mutations
  # Destroys a habit log for a user.
  class DestroyHabitLog < BaseMutation
    description 'Deletes a Habit Log for a user.'

    field :habit_log, Types::HabitLogType, null: false, description: 'The information for the habit log you deleted.'
    argument :habit_log_id, ID, required: true, description: 'The ID of the Habit Log.'

    def resolve(habit_log_id:)
      habit_log = HabitLog.find(habit_log_id)

      habit = Habit.find(habit_log.habit_id)

      unless user_has_access_to_habit(habit: habit)
        raise Errors::ForbiddenError.new('User does not have access to the Habit Log',
                                         errors: I18n.t('graphql_devise.errors.bad_id'))
      end

      habit_log.destroy

      { habit_log: habit_log }
    end
  end
end
