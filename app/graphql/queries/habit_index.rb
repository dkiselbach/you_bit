# frozen_string_literal: true

module Queries
  # Class for handling habit indexing
  class HabitIndex
    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def index(active: nil, frequency: nil)
      habits = user.habits.all

      habits = habits.inactive if active == false

      habits = habits.active if active == true

      return habits.with_certain_days(frequency.push('daily')) if frequency

      habits
    end
  end
end
