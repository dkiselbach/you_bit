# frozen_string_literal: true

module Mutations
  # Updates a Habit for a user.
  class UpdateHabit < BaseMutation
    description 'Updates a Habit for a User.'
    frequency_options = %w[daily monday tuesday wednesday thursday friday saturday sunday]

    field :habit, Types::HabitType, null: false, description: 'The information for the Habit you updated.'

    argument :habit_id, ID, required: true, description: 'The ID of the Habit.'
    argument :name, String, required: false, description: 'The Name of the Habit.'
    argument :active, Boolean, required: false, description: 'If the Habit is currently Active.'
    argument :description, String, required: false, description: 'The Description of the Habit.'
    argument :habit_type, String, required: false,
                                  description: "The Habit Type. This is either 'goal' or 'limit'. Defaults to 'goal'."
    argument :frequency, [String], required: false,
                                   description: "The Habit Frequency. This is one of: #{frequency_options}."
    argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: 'The Habit Start Date.'
    argument :category_name, String, required: false,
                                     description: 'The Category for the Habit. This will create a new
                                                   Category if the Category does not exist.'

    def resolve(habit_id:, **attrs)
      habit = find_habit_in_user_context(habit_id: habit_id)

      habit.update(**attrs)

      return { habit: habit } if habit.valid?

      raise Errors::ValidationError.new("Habit couldn't be updated",
                                        errors: habit.errors.messages)
    end
  end
end
