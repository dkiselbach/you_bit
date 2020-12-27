# frozen_string_literal: true

module Errors
  # Error for throwing user input errors in a graphql friendly format.
  class UserInputError < GraphQL::ExecutionError
    def initialize(message, errors:)
      @message = message
      @errors  = errors

      super(message)
    end

    def to_h
      byebug
      super.merge(extensions: { code: 'USER_INPUT_ERROR', detailed_errors: @errors })
    end
  end
end

