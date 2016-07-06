require 'rails_helper'

RSpec.describe InvitationPolicy do
  subject { described_class.new(user, invitation) }

  let(:invitation) { FactoryGirl.create(:invitation) }

  context 'being a visitor' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:create) }
  end

  context 'being the invitation event host' do
    let(:user) { invitation.event.host.user }

    it { is_expected.to permit_action(:create) }

    context 'when invitation event is closed' do
      let(:invitation) { FactoryGirl.create(:invitation, :to_event_closed) }

      it { is_expected.to forbid_action(:create) }

      it { is_expected.to have_authorization_error(:event_closed, on: :create) }
    end
  end

  context 'being an invitation event attendee' do
    let(:user) { FactoryGirl.create(:user) }

    before { invitation.event.attendees << user.profile }

    it { is_expected.to permit_action(:create) }

    context 'when invitation event is closed' do
      let(:invitation) { FactoryGirl.create(:invitation, :to_event_closed) }

      it { is_expected.to forbid_action(:create) }

      it { is_expected.to have_authorization_error(:event_closed, on: :create) }
    end
  end
end
