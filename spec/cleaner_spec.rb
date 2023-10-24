require 'cleaner'

describe Cleaner do
  subject { Cleaner.new(args) }
  let(:input_file_path) { "tmp/test.csv" }
  let(:output_file_path) { "tmp/output.csv" }
  let(:headers) { 
    [
      "first_name",
      "last_name",
      "dob",
      "member_id", 
      "effective_date",
      "expiry_date",
      "phone_number"
    ]
  }

  let(:cleanable_row) { 
    [
      "User",
      "Clean",
      "01/01/90",
      "333",
      "01/01/2010",
      "01/01/2030",
      "901-901-9011"
    ]
  }


  context 'with good input data' do
    let(:args) { { input_file: input_file_path, output_file: output_file_path } }
    let!(:rows) { [headers, cleanable_row] }
    let!(:csv) do
      CSV.open(input_file_path, "w") do |csv|
        rows.each do |row|
          csv << row
        end
      end
    end

    it 'produces cleaned output' do
      subject.transform
      output = CSV.open(output_file_path, 'r').to_a
      expect(output.count).to eq(2)
      # expect(output.last).to eq(cleaned_row)
    end
  end
end