class StartDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless start_date_valid?(value)
      record.errors.add(
        attribute,
        :invalid_start_date,
        message: options[:message] || 'Não é válido',
        value: value
      )
    end
  end

  private

  def start_date_valid?(date)
    date_obj = Date.parse(date.to_s) rescue nil

    return false unless date_obj

    date_obj >= Date.today
  end
end