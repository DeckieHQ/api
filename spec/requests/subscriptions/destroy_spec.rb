require 'rails_helper'

RSpec.describe 'Destroy event subscription', :type => :request do
  let(:event) { FactoryGirl.create(:event, :with_pending_subscriptions) }

  let(:subscription) { event.subscriptions.shuffle.last }

  before do
    delete subscription_path(subscription), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:authenticate) { user }

    context "when subscription doesn't exist" do
      let(:user) { FactoryGirl.create(:user) }

      let(:subscription) { { id: 0 } }

      it { is_expected.to return_not_found }
    end

    context 'when user has no access to the subscription' do
      let(:user) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it "doesn't destroy the subscription" do
        expect(subscription.reload).to be_persisted
      end
    end

    context 'when subscribtion belongs to the user' do
      let(:user) { subscription.profile.user }

      it { is_expected.to return_no_content }

      it 'destroys the subscription' do
        expect(Subscription.find_by(id: subscription.id)).to be_nil
      end

      # Test the service invokation. Therefore we don't need more tests here as
      # the service is heavily tested independantly.
      context 'when event is closed' do
        let(:event) { FactoryGirl.create(:event_closed, :with_pending_subscriptions) }

        it { is_expected.to return_forbidden }
      end
    end
  end
end
