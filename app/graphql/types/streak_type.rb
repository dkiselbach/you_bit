# frozen_string_literal: true

module Types
  # Type definition for the Streaks
  class StreakType < Types::BaseObject
    field :habit_streak, Integer, null: true, description: 'The longest consecutive streak.'
    field :start_date, GraphQL::Types::ISO8601Date, null: true, description: 'The Streak Start Date.'
    field :end_date, GraphQL::Types::ISO8601Date, null: true, description: 'The Streak End Date.'
  end
end
