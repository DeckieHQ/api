require 'rails_helper'

RSpec.describe SMS do
  let(:options) do
    { to: Faker::PhoneNumber.phone_number, message: Faker::Hipster.sentence }
  end

  subject(:sms) { SMS.new(options) }

  after do
    SMSDeliveries.clear
  end

  describe '#deliver_now' do

    context 'when provider call is successful' do
      before do
        SMSDeliveries.use_fake_provider
      end

      it 'returns true' do
        expect(sms.deliver_now).to be_truthy
      end

      it 'sends an sms with given options' do
        sms.deliver_now

        last_delivered = SMSDeliveries.last

        expect(last_delivered.options).to eql(options)
      end


    end

    context 'when provider call fails with a bad request' do
      before do
        SMSDeliveries.use_fake_provider(status: 400)
      end

      it 'returns false' do
        expect(sms.deliver_now).to be_falsy
      end

      it "doesn't send an sms" do
        expect(SMSDeliveries).to be_empty
      end
    end

    context 'when provider call fails with another response' do
      before do
        SMSDeliveries.use_fake_provider(status: 500)
      end

      it 'raises an error' do
        expect { sms.deliver_now }.to raise_error
      end
    end
  end
end
