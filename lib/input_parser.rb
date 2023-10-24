require 'date'

class InputParser
  HEADERS = %w[first_name last_name dob member_id effective_date expiry_date phone_number]
  START_RANGE = "01/01/1900".freeze
  END_RANGE = "01/01/2200".freeze
  DATE_FORMATS = ['%Y-%m-%d', '%y-%m-%d', '%m/%d/%y', '%m/%d/%Y', '%m-%d-%y']
  PARSE_TYPE_MAP = {
    'dob' => 'date',
    'effective_date' => 'date',
    'expiry_date' => 'date',
    'phone_number' => 'phone_number'
  }.freeze

  def parse(row, header)
    value = row[header]
    return if value.nil?
    value = value.strip
    value = send("parse_#{PARSE_TYPE_MAP[header]}", value) if PARSE_TYPE_MAP.key?(header)
    value
  end

  def parse_date(value)
    return if value.nil?
    date = parse_date_to_time(value)
    date.strftime('%Y-%m-%d')
  end

  def parse_date_to_time(value)
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

  def verify_date(date)
    (date > Date.strptime(START_RANGE, '%m/%d/%Y') && date < Date.strptime(END_RANGE, '%m/%d/%Y')) ? date : nil
  end

  def parse_phone_number(value)
    ['(', ')', ' ', '-'].each do |char|
      value.gsub!(char, '')
    end

    if value.length > 10
      country_code = value[0...-10]
      raise 'Invalid Country Code' unless country_code == '1'
    elsif value.length < 10
      raise 'Invalid Phone Number'
    end

    "+1#{value}"
  end
end