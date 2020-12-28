# frozen_string_literal: true

module Mutations
  # Destroys a habit for a user.
  class DestroyHabit < BaseMutation
    description 'Mutation for deleting a Habit for a user.'

    field :habit, Types::HabitType, null: false, description: 'The information for the habit you deleted.'
    argument :habit_id, ID, required: true, description: 'The ID of the Habit.'

    def resolve(habit_id:)
      user = current_resource
      habit = user.habits.find(habit_id)
      habit.destroy
      { habit: habit }

    rescue ActiveRecord::RecordNotFound
      raise Errors::UserInputError.new('Habit not found', errors: I18n.t('graphql_devise.errors.bad_id'))
    end
  end
end
