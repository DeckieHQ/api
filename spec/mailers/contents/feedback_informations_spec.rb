require 'rails_helper'

RSpec.describe FeedbackInformations do
  let(:feedback) { FactoryGirl.build(:feedback) }

  subject(:content) { described_class.new(feedback) }

  describe '#subject' do
    subject { content.subject }

    it do
      is_expected.to eq(
        I18n.t('mailer.feedback_informations.subject', title: feedback.title)
      )
    end
  end

  describe '#description' do
    subject { content.description }

    it { is_expected.to eq(feedback.description) }
  end
end
