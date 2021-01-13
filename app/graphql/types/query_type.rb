# frozen_string_literal: true

module Types
  # Class representing all queries within the Youbit app
  class QueryType < Types::BaseObject
    include GraphqlDevise::Concerns::ControllerMethods
    include ::GraphQlMixins::HelperMethods
    field :user, UserType, null: false, authenticate: true, description: 'Returns the currently signed in user.'
    field :habit_index, [Types::HabitType], null: false, authenticate: true,
                                            description: 'Returns the Habits of the signed in User.' do
      argument :days_of_week, [String], required: false,
                                        description: 'Filter by days of the week.'
      argument :active, Boolean, required: false,
                                 description: 'Specify if the habit is currently active. Defaults to true.'
    end
    field :categories_index, [Types::CategoryType], null: false, authenticate: true,
                                                    description: 'Returns the Categories of the signed in User.'
    field :reminders_index, [Types::ReminderType], null: false, authenticate: true,
                                                   description: 'Returns the Reminders of the signed in User.'
    field :habit, Types::HabitType, null: false, authenticate: true,
                                    description: 'Returns the Habit of the input Habit ID.' do
      argument :habit_id, ID, required: true, description: "ID of the Habit."
    end

    def user
      current_resource
    end

    def habit_index(**args)
      Queries::HabitIndex.new(current_resource).index(active: args[:active], frequency: args[:days_of_week])
    end

    def categories_index
      current_resource.categories.uniq
    end

    def reminders_index
      current_resource.reminders.uniq
    end

    def habit(habit_id:)
      find_object_in_user_context(object_id: habit_id, klass: Habit)
    end
  end
end
