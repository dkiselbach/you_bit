# frozen_string_literal: true

module Types
  # Class representing all queries within the Youbit app
  class QueryType < Types::BaseObject
    include GraphqlDevise::Concerns::ControllerMethods
    field :user, UserType, null: false, authenticate: true, description: 'Returns the currently signed in user.'
    field :habit_index, [Types::HabitType], null: false, authenticate: true, description: 'Returns' do
      argument :days_of_week, [String], required: false,
                                        description: 'Filter by days of the week.'
      argument :active, Boolean, required: false,
                                 description: 'Specify if the habit is currently active. Defaults to true.'
    end

    def user
      current_resource
    end

    def habit_index(**args)
      user = current_resource

      habits = user.habits.all
      habits = habits.inactive if args[:active] == false
      habits = habits.active if args[:active] == true

      return habits.with_certain_days(args[:days_of_week].push('daily')) if args[:days_of_week]

      habits
    end
  end
end
