require 'date'
require 'csv'
require 'set'

class Cleaner
  # DATE_FORMATS = ['%Y-%m-%d', '%y-%m-%d', '%m/%d/%y', '%m/%d/%Y']
  HEADERS = %w[first_name last_name dob member_id effective_date expiry_date phone_number]
  START_RANGE = "01/01/1900".freeze
  END_RANGE = "01/01/2200".freeze
  DATE_FORMATS = ['%Y-%m-%d', '%y-%m-%d', '%m/%d/%y', '%m/%d/%Y', '%m-%d-%y']


  def initialize
    # @input_file = input_file

    @parse_map = set_parse_map
    @output = initialize_output_file
    @member_ids = Set.new
    @excluded_rows = []
    @flagged_rows = []
  end

  def clean
    cached_output_row = {}

    CSV.foreach('input.csv', headers: true, encoding: 'bom|utf-8').with_index do |row, i|
      parsing_error = false
      row_errors = []

      HEADERS.each do |header|
        begin
          cached_output_row[header] = parse(row, header)
        rescue StandardError => e
          error = {
            "column": header,
            "error": e.message,
          }
          row_errors << error
          # ensure this value is recorded unparsed
          cached_output_row[header] = row[header]
          parsing_error = true
        end
      end

      if parsing_error
        process_error(cached_output_row, row_errors)
      else
        process_output(cached_output_row)
      end

      # do we need this? 
      cached_output_row.clear
    end

    build_results_file
  end

  def parse(row, header)
    value = row[header]
    return if value.nil?
    value = value.strip
    value = send("parse_#{@parse_map[header]}", value) if @parse_map.key?(header)
    value
  end

  def initialize_output_file
    csv = CSV.open('output.csv', 'w')
    csv << HEADERS
    csv
  end

  def initialize_results_file
    File.open('results.txt', 'w')
  end

  def process_error(cached_output_row, row_errors)
    row_with_errors = { row: cached_output_row.values, errors: row_errors }
    puts 'row with errors'
    puts row_with_errors
    @excluded_rows << row_with_errors
  end

  def process_output(cached_output_row)
    run_validations if @validate
    @output << cached_output_row.values
  end

  def run_validations(cached_output_row)
    validate_effective_expiry_date(cached_output_row)
    validate_member_id(cached_output_row)
  end

  def validate_effective_vs_expiry_date(cached_output_row)
    effective_date = Date.strptime(cached_output_row['effective_date'], '%Y-%m-%d')
    expiry_date = Date.strptime(cached_output_row['expiry_date'], '%Y-%m-%d')
    if effective_date > expiry_date
      result = {
        row: cached_output_row.values,
        failure: "The effective_date is later than the expiry_date."
      }

      @flagged_rows << result
    end
  end

  def validate_member_id(cached_output_row)
    if @member_ids.include?(cached_output_row['member_id'])
      result = {
        row: cached_output_row.values,
        failure: "Duplicate member_id."
      }

      @flagged_rows << result
    end
  end

  def set_parse_map
    {
      'dob' => 'date',
      'effective_date' => 'date',
      'expiry_date' => 'date',
      'phone_number' => 'phone_number'
    }
  end

  def build_results_file
    results_file = File.open('results.txt', 'w')
    results_file.puts "Number of rows excluded from parsing errors: #{@excluded_rows.count}"
    results_file.puts "Details: "
    @excluded_rows.each do |excluded_row|
      results_file.puts "Row: #{excluded_row[:row]}"
      results_file.puts "Errors: "
      excluded_row[:errors].each do |error|
        results_file.puts "#{error}"
      end

      results_file.puts ""
      results_file.puts ""
    end

    results_file.puts "-------------------------------------------------------------------"
    results_file.puts ""
    results_file.puts ""

    results_file.puts "Number of rows flagged for validation errors: #{@flagged_rows.count}"
    results_file.puts "Details: "
    @flagged_rows.each do |flagged_row|
      results_file.puts "Row: #{flagged_row[:row]}"
      results_file.puts "Failure: #{flagged_row[:failure]}"
      
      results_file.puts ""
      results_file.puts ""
    end

    results_file.puts "-------------------------------------------------------------------"
  end

  def parse_date(value)
    return if value.nil?
    date = parse_date_to_time(value)
    # puts "Parsed date string: #{date}"
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

Cleaner.new.clean