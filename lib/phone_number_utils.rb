class PhoneNumberUtils
  SEPARATORS = ['(', ')', ' ', '-', '+', '.'].freeze

  def to_e164(value)
    SEPARATORS.each do |char|
      value.gsub!(char, '')
    end

    if value.length > 10
      country_code = value[0...-10]
      raise ArgumentError.new('Invalid Country Code') unless country_code == '1'
      value = value[1..]
    elsif value.length < 10
      raise ArgumentError.new('Invalid Phone Number')
    end

    "+1#{value}"
  end
end