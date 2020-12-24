# frozen_string_literal: true

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    include GraphqlDevise::Concerns::ControllerMethods
  end
end
