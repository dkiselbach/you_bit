class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.public_send("#{attribute}_before_type_cast").present? && value.blank?
      record.errors.add(attribute, :invalid)
    end
  end
end