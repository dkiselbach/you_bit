# frozen_string_literal: true

module Mutations
  # Destroys a Reminder.
  class DestroyReminder < BaseMutation
    description 'Deletes a Reminder for a Habit.'

    field :reminder, Types::ReminderType, null: false, description: 'The information for the Reminder you deleted.'
    argument :reminder_id, ID, required: true, description: 'The ID of the Reminder.'

    def resolve(reminder_id:)
      reminder = Reminder.find(reminder_id)

      find_object_in_user_context(object_id: reminder.habit_id, klass: Habit)

      reminder.destroy

      { reminder: reminder }
    end
  end
end
