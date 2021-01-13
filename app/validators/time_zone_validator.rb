# frozen_string_literal: true

# Validates that the correct date format is given.
class TimeZoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value && ActiveSupport::TimeZone[value]

    record.errors.add(attribute, 'must be a valid time zone')
  end
end
