# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include GraphqlDevise::Concerns::ControllerMethods
    field :user, UserType, null: false, authenticate: true

    def user
      current_resource
    end
  end
end
