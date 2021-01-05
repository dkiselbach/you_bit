# frozen_string_literal: true

module Mutations
  # Creates a Habit Log for a habit.
  class CreateHabitLog < BaseMutation
    description 'Creates a Habit Log for a habit.'

    field :habit_log, Types::HabitLogType, null: false, description: 'The information for the Habit you logged.'

    argument :habit_id, ID, required: true, description: 'The ID of the Habit you want to log.'
    argument :habit_type, String, required: true,
                                  description: "The Habit Type. This is either 'goal' or 'limit'. Defaults to 'goal'."
    argument :logged_date, GraphQL::Types::ISO8601Date, required: true, description: 'The Habit Logged Date.'

    def resolve(habit_id:, habit_type:, logged_date:)
      habit = find_habit_in_user_context(habit_id: habit_id)

      habit_log = habit.habit_logs.create(habit_type: habit_type, logged_date: logged_date)

      return { habit_log: habit_log } if habit_log.valid?

      raise Errors::ValidationError.new("Habit Log couldn't be created",
                                        errors: habit.errors.messages)
    end
  end
end
