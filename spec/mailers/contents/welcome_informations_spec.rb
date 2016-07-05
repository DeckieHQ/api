require 'rails_helper'

RSpec.describe WelcomeInformations do
  let(:user) { FactoryGirl.create(:user) }

  subject(:content) { described_class.new(user) }

  describe '#username' do
    subject(:username) { content.username }

    it { is_expected.to eq(user.email) }
  end

  describe '#subject' do
    subject { content.subject }

    it do
      is_expected.to eq(I18n.t('mailer.welcome_informations.subject'))
    end
  end
end
