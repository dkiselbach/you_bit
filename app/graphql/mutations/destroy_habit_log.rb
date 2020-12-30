# frozen_string_literal: true

module Mutations
  # Destroys a habit log for a user.
  class DestroyHabitLog < BaseMutation
    description 'Deletes a Habit Log for a user.'

    field :habit_log, Types::HabitLogType, null: false, description: 'The information for the habit log you deleted.'
    argument :habit_log_id, ID, required: true, description: 'The ID of the Habit Log.'

    def resolve(habit_log_id:)
      habit_log = HabitLog.find(habit_log_id)

      user_has_access_to_habit = current_resource.habits.find_by(id: habit_log.habit_id).present?

      unless user_has_access_to_habit
        raise Errors::ForbiddenError.new('User does not have access to the Habit Log',
                                         errors: I18n.t('graphql_devise.errors.bad_id'))
      end

      habit_log.destroy

      { habit_log: habit_log }

    rescue ActiveRecord::RecordNotFound
      raise Errors::UserInputError.new('Habit Log not found', errors: I18n.t('graphql_devise.errors.bad_id'))
    end
  end
end
