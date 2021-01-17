# frozen_string_literal: true

module Errors
  # Error for throwing model validation errors in a graphql friendly format.
  class ValidationError < GraphQL::ExecutionError
    def initialize(message, errors:)
      @message = message
      @errors  = errors

      super(message)
    end

    def to_h
      super.merge(extensions: { code: 'VALIDATION_ERROR', detailed_errors: @errors })
    end
  end
end
