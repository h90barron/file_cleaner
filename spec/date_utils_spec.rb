require 'date_utils'

describe 'DateUtils' do
  subject { DateUtils.new }
  describe '#to_iso8601' do
    context 'with a parsable input date' do
      let(:parsable_date) { '1/1/88'}
      let(:parsed_date) { '1988-01-01' }

      it 'returns iso8601 formatted date' do
        expect(subject.to_iso8601(parsable_date)).to eq(parsed_date)
      end
    end

    context 'with an unparsable input date' do
      let(:unparsable_date) { '1/101/88' }

      it 'raises an ArgumentError' do
        expect { subject.to_iso8601(unparsable_date) }.to raise_error(ArgumentError)
      end
    end
  end
end