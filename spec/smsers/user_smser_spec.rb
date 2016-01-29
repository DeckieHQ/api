require 'rails_helper'

RSpec.describe UserSMSer do
  let(:user) { FactoryGirl.create(:user_with_phone_number_verification) }

  let(:sms) { UserSMSer.phone_number_verification_instructions(user) }

  describe '#phone_number_verification_instructions' do
    it 'renders the sender phone number' do
      expect(sms[:to]).to eq(user.phone_number)
    end

    it 'renders the verification message' do
      expected_message = I18n.t(
        'verifications.phone_number.message',
        code: user.phone_number_verification_token
      )
      expect(sms[:message]).to eq expected_message
    end

    it 'can be delivered' do
      expect(sms).to respond_to(:deliver_now)
    end
  end
end