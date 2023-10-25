require 'phone_number_utils'

describe PhoneNumberUtils do
  subject { PhoneNumberUtils.new }

  describe '#to_e164' do
    context 'with parsable phone number input' do
      let(:parsable_phone_number) { '+1(501) 123-4567' }
      let(:parsed_phone_number) { '+15011234567' }

      it 'returns the E.164 formatted number' do
        expect(subject.to_e164(parsable_phone_number)).to eq(parsed_phone_number)
      end
    end

    context 'with unparsable phone number input' do
      let(:unparsable_phone_number) { '+4(501) 123-4567 55'}

      it 'raises ArgumentError' do
        expect { subject.to_e164(unparsable_phone_number) }.to raise_error(ArgumentError)
      end
    end
  end
end