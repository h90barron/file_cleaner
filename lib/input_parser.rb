require 'date_utils'
require 'phone_number_utils'

class InputParser
  PARSE_TYPE_MAP = {
    'dob' => 'date',
    'effective_date' => 'date',
    'expiry_date' => 'date',
    'phone_number' => 'phone_number'
  }.freeze

  def initialize
    @date_parser = DateUtils.new
    @phone_number_parser = PhoneNumberUtils.new
  end

  def parse(value, header)
    return if value.nil?
    value = value.strip
    value = send("parse_#{PARSE_TYPE_MAP[header]}", value) if PARSE_TYPE_MAP.key?(header)
    value
  end

  def parse_date(value)
    @date_parser.to_iso8601(value)
  end

  def parse_phone_number(value)
    @phone_number_parser.to_e164(value)
  end
end