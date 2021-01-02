# frozen_string_literal: true

module Types
  # Type definition for the habits model
  class HabitType < Types::BaseObject
    field :id, ID, null: false, description: 'The Unique Identifier for the Habit.'
    field :name, String, null: false, description: 'The Name of the Habit.'
    field :habit_type, String, null: false, description: "The Habit Type. This is either 'goal' or 'limit'."
    field :active, Boolean, null: false, description: 'If the Habit is currently Active.'
    field :description, String, null: true, description: 'The Description of the Habit.'
    field :frequency, [String], null: false, description: 'The Habit Frequency.'
    field :category, Types::CategoryType, null: false, description: 'The Category associated with the Habit.'
    field :start_date, GraphQL::Types::ISO8601Date, null: false, description: 'The Habit Start Date.'
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the Habit was created.'
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the Habit was updated.'
    field :habit_logs, [Types::HabitLogType], null: true, description: 'Logs for the Habit.'
    field :is_logged, Types::IsLoggedType, null: false, description: 'If the Habit has been Logged.' do
      argument :selected_date, GraphQL::Types::ISO8601Date, required: true
    end
    field :longest_streak, Types::StreakType, null: true, description: 'The Longest Streak for the habit.'
    field :current_streak, Types::StreakType, null: true, description: 'The Current Streak for the habit.' do
      argument :selected_date, GraphQL::Types::ISO8601Date, required: true
    end

    def habit_logs
      @object.habit_logs.order('logged_date DESC')
    end

    def is_logged(**args)
      @object.logged(args[:selected_date])
    end

    def longest_streak
      @object.longest_streak
    end

    def current_streak(**args)
      @object.current_streak(args[:selected_date])
    end
  end
end
