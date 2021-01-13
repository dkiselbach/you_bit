# frozen_string_literal: true

module Validators
  # Class for testing custom validations
  class Validatable
    include ActiveModel::Validations

    attr_accessor :date, :habit_type, :time_zone

    validates :date, date: true
    validates :habit_type, habit_type: true
    validates :time_zone, time_zone: true

    def date_before_type_cast
      date
    end
  end
end