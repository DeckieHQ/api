require 'rails_helper'

RSpec.describe UserSMSer do
  let(:user) { FactoryGirl.create(:user_with_phone_number_verification, culture: 'fr') }

  let(:sms) { described_class.phone_number_verification_instructions(user) }

  describe '#phone_number_verification_instructions' do
    it 'renders the sender phone number' do
      expect(sms[:to]).to eq(user.phone_number)
    end

    it 'renders the verification instructions message' do
      expect(sms[:message]).to eq(
        I18n.t('smser.phone_number_verification_instructions.message',
          code: user.phone_number_verification_token, locale: user.culture
        )
      )
    end

    it 'can be delivered' do
      expect(sms).to respond_to(:deliver_now)
    end
  end
end
