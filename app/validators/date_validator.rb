# frozen_string_literal: true

# Validates that the correct date format is given.
class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Date.parse(record.public_send("#{attribute}_before_type_cast").to_s)
  rescue Date::Error
    record.errors.add(attribute, 'must be a valid date')
  end
end
