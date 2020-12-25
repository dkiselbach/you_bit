# frozen_string_literal: true

module Types
  # Class representing all queries within the Youbit app
  class QueryType < Types::BaseObject
    include GraphqlDevise::Concerns::ControllerMethods
    field :user, UserType, null: false, authenticate: true, description: 'Returns the currently signed in user.'

    def user
      current_resource
    end
  end
end
