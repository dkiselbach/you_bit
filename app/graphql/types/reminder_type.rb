# frozen_string_literal: true

module Types
  # Type definition for the Reminder model
  class ReminderType < Types::BaseObject
    field :id, ID, null: false, description: 'The Unique Identifier for the Reminder.'
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the Reminder was created.'
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false,
                                                        description: 'The DateTime value of when the Reminder was updated.'
    field :remind_at, GraphQL::Types::ISO8601DateTime, null: false, description: 'The time to remind the User.'
    field :habit, Types::HabitType, null: false, description: 'The Habit the Reminder belongs to.'
  end
end
