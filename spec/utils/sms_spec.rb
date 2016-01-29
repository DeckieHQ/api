require 'rails_helper'

RSpec.describe SMS do
  let(:options) do
    { to: Faker::PhoneNumber.phone_number, message: Faker::Hipster.sentence }
  end

  subject(:sms) { SMS.new(options) }

  before do
    SMSDeliveries.use_fake_provider
    SMSDeliveries.clear
  end

  describe '#deliver_now' do
    before do
      sms.deliver_now
    end

    it 'sends an sms with given options' do
      last_delivered = SMSDeliveries.last

      expect(last_delivered.options).to eql(options)
    end
  end
end
