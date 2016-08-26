require 'rails_helper'

RSpec.describe WelcomeInformations do
  let(:user) { FactoryGirl.create(:user) }

  subject(:content) { described_class.new(user) }

  describe '#subject' do
    subject { content.subject }

    it do
      is_expected.to eq(I18n.t('mailer.welcome_informations.subject'))
    end
  end

  describe '#details' do
    subject { content.details }

    it do
      is_expected.to eq(
        I18n.t('mailer.welcome_informations.details').gsub("\n", '<br><br>')
      )
    end
  end

  describe '#search_url' do
    subject { content.search_url }

    it { is_expected.to equal_front_url_with('search') }
  end
end
