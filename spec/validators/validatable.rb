# frozen_string_literal: true

module Validators
  # Class for testing custom validations
  class Validatable
    include ActiveModel::Validations

    attr_accessor :date, :habit_type

    validates :date, date: true
    validates :habit_type, habit_type: true

    def date_before_type_cast
      date
    end
  end
end