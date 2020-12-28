# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    include GraphqlDevise::Concerns::ControllerMethods
    field :create_habit, mutation: Mutations::CreateHabit, authenticate: true
    field :destroy_habit, mutation: Mutations::DestroyHabit, authenticate: true
  end
end
