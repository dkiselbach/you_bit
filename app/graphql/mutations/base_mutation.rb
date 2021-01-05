# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    include GraphqlDevise::Concerns::ControllerMethods
    include ActiveSupport::Concern
    include ::GraphQlMixins::HabitHelpers
    argument_class Types::BaseArgument
    field_class Types::BaseField
    object_class Types::BaseObject
  end
end
