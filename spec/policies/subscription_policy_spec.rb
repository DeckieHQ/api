require 'rails_helper'

RSpec.describe SubscriptionPolicy do
  subject { SubscriptionPolicy.new(user, subscription) }

  let(:subscription) { FactoryGirl.create(:subscription, :pending) }

  context 'being a visitor' do
    let(:user) { FactoryGirl.create(:user) }

    it { is_expected.to forbid_action(:show)    }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:confirm) }
  end

  context 'being the subscribtion event host' do
    let(:user) { subscription.event.host.user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:confirm) }

    [:closed, :full].each do |type|
      context "when subscription event is #{type}" do
        let(:subscription) do
          FactoryGirl.create(:subscription, :"to_event_#{type}")
        end

        it { is_expected.to forbid_action(:confirm)  }
      end
    end

    context 'when subscription is already confirmed' do
      let(:subscription) { FactoryGirl.create(:subscription, :confirmed) }

      it { is_expected.to forbid_action(:confirm) }
    end
  end

  context 'being the subscribtion owner' do
    let(:user) { subscription.profile.user }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to forbid_action(:confirm) }

    context 'when subscription event is closed' do
      let(:subscription) do
        FactoryGirl.create(:subscription, :to_event_closed)
      end

      it { is_expected.to forbid_action(:destroy) }
    end
  end
end
