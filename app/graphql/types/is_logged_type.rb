# frozen_string_literal: true

module Types
  # Type definition for the habits model
  class IsLoggedType < Types::BaseObject
    field :habit_log, Types::HabitLogType, null: true, description: 'Habit Log associated with Logged.'
    field :logged, Boolean, null: false, description: 'If the Habit has been Logged.'
  end
end
