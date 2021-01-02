# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :habits, dependent: :nullify
  has_many :users, through: :habits
  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
