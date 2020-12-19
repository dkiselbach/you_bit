# frozen_string_literal: true

Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'
  # mount_graphql_devise_for 'User', at: 'graphql_auth'
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: 'graphql#execute'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
