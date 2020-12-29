# frozen_string_literal: true

# Validates that the correct habit type format is given.
class HabitTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    types = %w[goal limit]

    return if types.include?(value)

    record.errors.add(attribute, "Must be either 'goal' or 'limit'" )
  end
end
