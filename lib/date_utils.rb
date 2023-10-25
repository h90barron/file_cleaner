require 'date'

class DateUtils
  START_RANGE = "1900-01-01".freeze
  END_RANGE = "2200-01-01".freeze
  DATE_FORMATS = [
    '%Y-%m-%d', 
    '%y-%m-%d', 
    '%m/%d/%Y', 
    '%m/%d/%y', 
    '%m-%d-%Y',
    '%m-%d-%y'
  ].freeze
  ISO8601_FORMAT = '%Y-%m-%d'.freeze

  def to_iso8601(value)
    date = parse_string_date_to_time(value)
    date.strftime(ISO8601_FORMAT)
  end

  private

  # TODO - refactor this
  def parse_string_date_to_time(value)
    date = nil
    DATE_FORMATS.each do |date_format|
      date = parse_date_with_formats(value, date_format)
      if date.nil?
        next
      else
        return date
      end
    end

    raise ArgumentError.new 'Invalid date format' if date.nil?
    date
  end

  def parse_date_with_formats(value, date_format)
    begin
      date = Date.strptime(value, date_format)
    rescue ArgumentError
      date = nil
    end

    date = verify_date(date) unless date.nil?
    date
  end

  # since we are unsure of input format there is a chance a date could be
  # parsed but still be incorrect. using this range check as a catch for that
  # eg 
  # 9/30/19 with 'm/d/Y' = 0019-30-09      no error but incorrect
  # 9/30/19 with 'm/d/y' = 2019-30-09      no error and correct
  # if date is out of range, return nil
  def verify_date(date)
    after_start_date = (date > Date.strptime(START_RANGE, ISO8601_FORMAT))
    before_end_date = (date < Date.strptime(END_RANGE, ISO8601_FORMAT))
    after_start_date && before_end_date ? date : nil
  end
end