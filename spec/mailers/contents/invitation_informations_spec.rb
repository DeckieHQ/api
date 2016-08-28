require 'rails_helper'

RSpec.describe InvitationInformations do
  let(:invitation) { FactoryGirl.create(:invitation) }

  subject(:content) { described_class.new(invitation) }

  describe '#subject' do
    subject { content.subject }

    it do
      is_expected.to eq(
        I18n.t('mailer.invitation_informations.subject',
          display_name: invitation.sender.display_name, title: invitation.event.title
        )
      )
    end
  end

  describe '#details' do
    subject { content.details }

    it do
      is_expected.to eq(
        I18n.t('mailer.invitation_informations.subject',
          display_name: "<b>#{invitation.sender.display_name}</b>",
          title: "<b>#{invitation.event.title}</b>"
        )
      )
    end
  end

  describe '#when' do
    subject { content.when }

    it do
      is_expected.to eq(
        I18n.t('mailer.invitation_informations.when',
          begin_at: "<b>#{invitation.event.begin_at}</b>"
        )
      )
    end
  end

  describe '#address' do
    subject { content.address }

    it do
      is_expected.to eq(
        I18n.t('mailer.invitation_informations.address',
          street: invitation.event.street, city: invitation.event.city,
          state: invitation.event.state, country: invitation.event.country
        )
      )
    end
  end

  describe '#capacity_range' do
    subject { content.capacity_range }

    it do
      is_expected.to eq(
        I18n.t('mailer.invitation_informations.capacity_range',
          min_capacity: invitation.event.min_capacity, capacity: invitation.event.capacity
        )
      )
    end
  end

  describe '#short_description' do
    subject { content.short_description }

    it { is_expected.to eq(invitation.event.short_description) }
  end

  describe '#message' do
    subject { content.message }

    it { is_expected.to eq(invitation.message) }
  end

  describe '#invitation_url' do
    subject { content.invitation_url }

    it { is_expected.to equal_front_url_with("event/#{invitation.event.id}") }
  end
end
