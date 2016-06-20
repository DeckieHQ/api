require 'rails_helper'

RSpec.describe PreferencesPolicy do
  subject { described_class.new(user, preferences) }

  let(:preferences) { FactoryGirl.build(:preferences) }

  context 'being the preferences owner' do
    let(:user) { preferences.user }

    it { is_expected.to permit_action(:show)   }
    it { is_expected.to permit_action(:update) }
  end

  context 'being another user' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:show)   }
    it { is_expected.to forbid_action(:update) }
  end
end
