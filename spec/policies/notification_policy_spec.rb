require 'rails_helper'

RSpec.describe NotificationPolicy do
  subject { described_class.new(user, notification) }

  let(:notification) { FactoryGirl.create(:notification) }

  context 'being the notification owner' do
    let(:user) { notification.user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:view) }
  end

  context 'being another user' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:view) }
  end
end
