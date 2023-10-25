require 'csv'
require 'set'
require 'input_parser'

class Cleaner
  HEADERS = %w[
    first_name 
    last_name 
    dob 
    member_id 
    effective_date 
    expiry_date 
    phone_number
  ].freeze

  def initialize(input_file:, output_file:, validate:)
    @input_file = input_file
    @output = initialize_output_file(output_file)
    @validate = validate
    
    @parser = InputParser.new
    @member_ids = Set.new
    @excluded_rows = []
    @flagged_rows = []
  end

  def clean
    cached_output_row = {}

    CSV.foreach(@input_file, headers: true, encoding: 'bom|utf-8').with_index do |row, i|
      parsing_error = false
      row_errors = []

      HEADERS.each do |header|
        begin
          cached_output_row[header] = @parser.parse(row[header], header)
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

      cached_output_row.clear
    end

    build_report_file
    close_output_file
  end

  def initialize_output_file(output_file)
    csv = CSV.open(output_file, 'w')
    csv << HEADERS
    csv
  end

  def process_error(cached_output_row, row_errors)
    row_with_errors = { row: cached_output_row.values, errors: row_errors }
    @excluded_rows << row_with_errors
  end

  def process_output(cached_output_row)
    run_validations(cached_output_row) if @validate
    @output << cached_output_row.values
  end

  # TODO - move validation and report file workflow out of this class
  def run_validations(cached_output_row)
    validate_effective_expiry_date(cached_output_row)
    validate_member_id(cached_output_row)
  end

  def validate_effective_expiry_date(cached_output_row)
    return unless cached_output_row['effective_date'] && cached_output_row['expiry_date']

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
    return unless cached_output_row['member_id']

    if @member_ids.include?(cached_output_row['member_id'])
      result = {
        row: cached_output_row.values,
        failure: "Duplicate member_id."
      }

      @flagged_rows << result
    else
      @member_ids << cached_output_row['member_id']
    end
  end

  def build_report_file
    results_file = File.open('report.txt', 'w')
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
    results_file.close
  end

  def close_output_file
    @output.close
  end
end