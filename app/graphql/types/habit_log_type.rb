# frozen_string_literal: true

module Types
  # Type definition for the habits model
  class HabitLogType < Types::BaseObject
    field :id, ID, null: false, description: 'The Unique Identifier for the Habit Log.'
    field :habit_type, String, null: false, description: "The Habit Type. This is either 'goal' or 'limit'."
    field :logged_date, GraphQL::Types::ISO8601Date, null: false, description: 'The Habit Logged Date.'
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the Habit Log was created.'
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the Habit Log was updated.'
    field :habit, Types::HabitType, null: false, description: 'Habit that was logged.'
  end
end
