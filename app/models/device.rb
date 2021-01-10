class Device < ApplicationRecord
  validates :token, presence: true
  validates :platform, presence: true, inclusion: { in: %w[iOS Android Web] }
  belongs_to :user
end
