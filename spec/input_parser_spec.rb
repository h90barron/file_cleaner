require 'input_parser'

describe InputParser do
  subject { InputParser.new }
  let(:date_header) { 'dob' }
  let(:phone_header) { 'phone_number' }
  let(:other_header) { 'first_name' }

  describe 'with parsable data' do
    let(:parsable_other) { 'James '}
    let(:parsable_date) { '1/1/88' }
    let(:parsable_phone_number) { '(555) 555-1234' }

    context 'of date type' do
      it 'converts the date to Y-m-d format' do
        expect(subject.parse(parsable_date, date_header)).to eq('1988-01-01')
      end
    end

    context 'of phone number type' do
      it 'converts the phone number to E.164' do
        expect(subject.parse(parsable_phone_number, phone_header)).to eq('+15555551234')
      end
    end

    context 'of non-phone and non-date type' do
      it 'removes extra white space' do
        expect(subject.parse(parsable_other, other_header)).to eq('James')
      end
    end
  end

  describe 'with unparsable data' do
    let(:parsable_non_date_non_phone_number) { }
    let(:parsable_date) { '111/1/88' }
    let(:unparsable_phone_number) { '(11555) 555-1234' }

    context 'of date type' do
      it 'raises an error' do
        expect { subject.parse(unparsable_date, date_header) }
          .to raise_error
      end
    end

    context 'of phone number type' do
      it 'raises an error'  do
        expect { subject.parse(unparsable_phone_number, phone_header) }
          .to raise_error
      end
    end
  end
end