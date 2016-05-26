require 'rails_helper'

RSpec.describe Feedback, :type => :model do
  describe 'Validations' do
    [:title, :description].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end

    { title: 128, description: 8192 }.each do |attribute, length|
      it { is_expected.to validate_length_of(attribute).is_at_most(length) }
    end
  end

  describe '#send_email' do
    let(:feedback) { FactoryGirl.build(:feedback) }

    let(:informations_mail) { double(:deliver_later) }

    it 'plans to deliver later a feeedback informations email' do
      allow(FeedbackMailer).to receive(:informations).with(feedback)
        .and_return(informations_mail)

      expect(informations_mail).to receive(:deliver_later).with(no_args)

      feedback.send_email
    end
  end
end
