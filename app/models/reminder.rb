# frozen_string_literal: true

# A class for the Reminder model.
class Reminder < ApplicationRecord
  validates :remind_at, date: true, presence: true
  belongs_to :habit
end
