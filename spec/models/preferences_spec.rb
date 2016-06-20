require 'rails_helper'

RSpec.describe Preferences, :type => :model do
  describe 'Validations' do
    it { is_expected.to allow_value(%w(event-update)).for(:notifications) }

    it { is_expected.to_not allow_value(%w(unsupported)).for(:notifications) }

    it { is_expected.to_not allow_value(nil).for(:notifications) }

    it { is_expected.to_not allow_value('string').for(:notifications) }
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

  describe '#id' do
    let(:preferences) { FactoryGirl.build(:preferences) }

    it 'is equal to its user id' do
      expect(preferences.id).to eq(preferences.user.id)
    end
  end

  describe '#update' do
    let(:params) { FactoryGirl.build(:preferences).attributes }

    let(:preferences) { FactoryGirl.build(:preferences) }

    subject(:update) { preferences.update(params) }

    before do
      update

      preferences.user.reload
    end

    it { is_expected.to be_truthy }

    it 'updates its user preferences' do
      expect(preferences.user.preferences).to eq(preferences.attributes)
    end

    context 'when parameters are invalid' do
      let(:params) { FactoryGirl.build(:preferences_invalid).attributes }

      it { is_expected.to be_falsy }

      it "doesn't update its user preferences" do
        expect(preferences.user.preferences).to_not eq(preferences.attributes)
      end

      it 'has validations error' do
        expect(preferences.errors).to_not be_empty
      end
    end
  end

  describe '.for' do
    let(:user) { FactoryGirl.create(:user) }

    subject(:preferences) { Preferences.for(user) }

    it 'assigns the user' do
      expect(preferences.user).to eq(user)
    end

    it 'returns the preferences of an user' do
      expect(preferences.attributes).to eq(user.preferences)
    end
  end
end
