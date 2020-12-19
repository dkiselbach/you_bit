# frozen_string_literal: true

class YouBitSchema < GraphQL::Schema
  use GraphqlDevise::SchemaPlugin.new(
    query: Types::QueryType,
    mutation: Types::MutationType,
    authenticate_default: false,
    resource_loaders: [
      GraphqlDevise::ResourceLoader.new('User', { at: 'graphql', operations: { sign_up: Mutations::SignUp }, skip: %i[confirm_account] })
    ]
  )

  mutation(Types::MutationType)
  query(Types::QueryType)

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  # Add built-in connections for pagination
  use GraphQL::Pagination::Connections
end
