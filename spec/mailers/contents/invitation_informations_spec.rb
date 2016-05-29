require 'rails_helper'

RSpec.describe InvitationInformations do
  let(:invitation) { FactoryGirl.create(:invitation) }

  subject(:content) { described_class.new(invitation) }

  describe '#subject' do
    subject { content.subject }

    it do
      is_expected.to eq(
        I18n.t('mailer.invitation_informations.subject', title: invitation.event.title)
      )
    end
  end

  describe '#username' do
    subject { content.username }

    it { is_expected.to eq(invitation.email) }
  end

  describe '#details' do
    subject { content.details }

    it do
      is_expected.to eq(
        I18n.t('mailer.invitation_informations.details', sender: invitation.profile.display_name)
      )
    end
  end

  describe '#message' do
    subject { content.message }

    it { is_expected.to eq(invitation.message) }
  end

  describe '#invitation_url' do
    subject { content.invitation_url }

    it { is_expected.to equal_front_url_with("events/#{invitation.event.id}") }
  end
end
