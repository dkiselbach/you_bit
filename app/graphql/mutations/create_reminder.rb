# frozen_string_literal: true

module Mutations
  # Creates a reminder for a habit.
  class CreateReminder < BaseMutation
    description 'Creates a reminder for a habit.'

    field :reminder, Types::ReminderType, null: false, description: 'The information for the Reminder you created.'

    argument :remind_at, GraphQL::Types::ISO8601DateTime, required: true,
                                          description: 'The time the User will be reminded of the Habit.'
    argument :habit_id, ID, required: true,
                            description: 'The Habit to associate the Reminder with.'

    def resolve(remind_at:, habit_id:)
      habit = find_object_in_user_context(klass: Habit, object_id: habit_id)

      reminder = habit.reminders.create(remind_at: remind_at)

      return { reminder: reminder } if reminder.valid?

      raise Errors::ValidationError.new("Reminder couldn't be created",
                                        errors: reminder.errors.messages)
    end
  end
end
