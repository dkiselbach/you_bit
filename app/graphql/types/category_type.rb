# frozen_string_literal: true

module Types
  # Type definition for the Category model
  class CategoryType < Types::BaseObject
    field :id, ID, null: false, description: 'The Category ID.'
    field :name, String, null: false, description: 'The Category Name.'
  end
end
