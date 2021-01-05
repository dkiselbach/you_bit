# frozen_string_literal: true

# you_bit main GraphQL schema
class YouBitSchema < GraphQL::Schema
  use GraphqlDevise::SchemaPlugin.new(
    query: Types::QueryType,
    mutation: Types::MutationType,
    authenticate_default: false,
    resource_loaders: [
      GraphqlDevise::ResourceLoader.new('User',
                                        { at: 'graphql',
                                          operations: { sign_up: Mutations::SignUp, login: Mutations::Login,
                                                        send_password_reset: Mutations::SendPasswordReset,
                                                        check_password_token: Resolvers::CheckPasswordToken },
                                          only: %i[login logout sign_up update_password
                                                   send_password_reset check_password_token] })
    ]
  )

  mutation(Types::MutationType)
  query(Types::QueryType)

  # Opt in to the new runtime (default in future graphql-ruby versions)
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  # Add built-in connections for pagination
  use GraphQL::Pagination::Connections

  # Error handling
  use GraphQL::Execution::Errors

  rescue_from(ActiveRecord::RecordNotFound) do |err, obj, args, ctx, field|
    raise Errors::UserInputError.new(err.message,
                                     errors: I18n.t('graphql_devise.errors.bad_id'))
  end
end
