require 'rails_helper'

RSpec.describe FeedbackMailer do
  let(:feedback) { FactoryGirl.build(:feedback) }

  describe '#informations' do
    let(:mail) { described_class.informations(feedback) }

    let(:content) { FeedbackInformations.new(feedback) }

    let(:default_email_signature) do
      Rails.application.config.action_mailer.default_options[:from]
    end

    it 'adds the default email signature to the senders' do
      expect(mail.from).to eq([default_email_signature])
    end

    it 'adds the default email signature to the receivers' do
      expect(mail.to).to eq([default_email_signature])
    end

    it 'sets the subject' do
      expect(mail.subject).to eq(content.subject)
    end

    [:description, :sender].each do |attribute|
      it "assigns #{attribute}" do
        expect(mail.body.encoded).to include(content.public_send(attribute))
      end
    end
  end
end
