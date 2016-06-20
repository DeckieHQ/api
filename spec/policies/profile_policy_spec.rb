require 'rails_helper'

RSpec.describe ProfilePolicy do
  subject { described_class.new(user, profile) }

  let(:profile) { FactoryGirl.create(:profile) }

  context 'being the profile owner' do
    let(:user) { profile.user }

    it { is_expected.to permit_action(:update) }
  end

  context 'being another user' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:update) }
  end
end
