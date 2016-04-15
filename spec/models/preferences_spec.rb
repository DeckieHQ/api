require 'rails_helper'

RSpec.describe Preferences, :type => :model do
  describe 'Validations' do
    it { is_expected.to allow_value(%w(event-update)).for(:notifications) }

    it { is_expected.to_not allow_value(%w(unsupported)).for(:notifications) }
  end

  describe 'beforeValidation' do
    subject(:preferences) do
      FactoryGirl.build(:preferences, notifications: notifications)
    end

    before { preferences.valid? }

    context 'when notifications has duplicates' do
      let(:notifications) { %w(event-update event-update event-submit) }

      it 'removes the duplicates' do
        expect(preferences.notifications).to eq(notifications.uniq)
      end
    end
  end

  describe '#attributes' do
    let(:preferences) { FactoryGirl.build(:preferences) }

    subject { preferences.attributes }

    it 'returns the attributes hash' do
      is_expected.to eq({
        'notifications' => preferences.notifications
      })
    end
  end
end
