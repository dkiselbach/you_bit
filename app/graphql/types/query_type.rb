# frozen_string_literal: true

module Types
  # Class representing all queries within the Youbit app
  class QueryType < Types::BaseObject
    include GraphqlDevise::Concerns::ControllerMethods
    field :user, UserType, null: false, authenticate: true, description: 'Returns the currently signed in user.'
    field :habit_index, [Types::HabitType], null: false, authenticate: true,
                                            description: 'Returns the Habits of the signed in User.' do
      argument :days_of_week, [String], required: false,
                                        description: 'Filter by days of the week.'
      argument :active, Boolean, required: false,
                                 description: 'Specify if the habit is currently active. Defaults to true.'
    end

    def user
      current_resource
    end

    def habit_index(**args)
      Queries::HabitIndex.new(current_resource).index(args[:active], args[:days_of_week])
    end
  end
end
