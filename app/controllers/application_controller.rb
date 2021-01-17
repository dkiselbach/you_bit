# frozen_string_literal: true

class ApplicationController < ActionController::API
  include GraphqlDevise::Concerns::SetUserByToken
end
