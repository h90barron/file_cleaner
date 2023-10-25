require 'cleaner'

describe Cleaner do
  subject { Cleaner.new(args) }
  let(:args) { 
    { 
      input_file: input_file_path, 
      output_file: output_file_path,
      validate: true 
    } 
  }
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

  let(:uncleanable_row) { 
    [
      "User",
      "Unparsable_Dates",
      "19/19/19",
      "333",
      "01/01/201",
      "011/01/2030",
      "901-901-9011"
    ]
  }

  let(:missing_required_fields_row) {
    [
      "User",
      "Clean",
      "01/01/90",
      "",
      "",
      "01/01/2030",
      "901-901-9011"
    ]
  }

  describe '#clean' do
    context 'with good input data' do 
      let!(:rows) { [headers, cleanable_row] }
      let!(:csv) do
        CSV.open(input_file_path, "w") do |csv|
          rows.each do |row|
            csv << row
          end
        end
      end

      it 'produces cleaned output' do
        subject.clean
        output = CSV.open(output_file_path, 'r').to_a
        expect(output.count).to eq(2)
      end
    end 

    context 'with bad input data' do  
      let!(:rows) { [headers, uncleanable_row] }
      let!(:csv) do
        CSV.open(input_file_path, "w") do |csv|
          rows.each do |row|
            csv << row
          end
        end
      end

      it 'handles ArgumentError' do
        expect { subject.clean }.to_not raise_error(ArgumentError)
      end

      it 'does not write error rows to the output file' do
        subject.clean
        output = CSV.open(output_file_path, 'r').to_a
        expect(output.count).to eq(1)
        expect(output.first).to eq(headers)
      end
    end

    context 'with missing required fields' do
      let!(:rows) { [headers, missing_required_fields_row] }
      let!(:csv) do
        CSV.open(input_file_path, "w") do |csv|
          rows.each do |row|
            csv << row
          end
        end
      end

      it 'does not write error rows to the output file' do
        subject.clean
        output = CSV.open(output_file_path, 'r').to_a
        expect(output.count).to eq(1)
        expect(output.first).to eq(headers)
      end
    end
  end
end