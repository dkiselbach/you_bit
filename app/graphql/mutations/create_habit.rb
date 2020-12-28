# frozen_string_literal: true

module Mutations
  # Creates a habit for a user.
  class CreateHabit < BaseMutation
    description 'Mutation for creating a Habit for a user.'
    frequency_options = %w[daily week-days week-ends monday tuesday wednesday thursday friday saturday sunday]

    field :habit, Types::HabitType, null: false, description: 'The information for the habit you want to create.'

    argument :name, String, required: true, description: 'The Name of the Habit.'
    argument :description, String, required: false, description: 'The Description of the Habit.'
    argument :habit_type, String, required: false,
                                  description: "The Habit Type. This is either 'goal' or 'limit'. Defaults to 'goal'."
    argument :frequency, [String], required: true,
                                   description: "The Habit Frequency. This is one of: #{frequency_options}."
    argument :start_date, GraphQL::Types::ISO8601Date, required: true, description: 'The Habit Start Date.'

    def resolve(**attrs)
      habit = current_resource.habits.create(attrs)

      return { habit: habit } if habit.valid?

      raise Errors::ValidationError.new("Habit couldn't be created",
                                        errors: habit.errors.messages)
    end
  end
end
