require 'rails_helper'

RSpec.describe 'Confirm event subscription', :type => :request do
  let(:event) { FactoryGirl.create(:event, :with_pending_subscriptions) }

  let(:subscription) { event.subscriptions.shuffle.last }

  before do
    post confirm_subscription_path(subscription), headers: json_headers
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

      it "doesn't confirm the subscription" do
        expect(subscription.reload).to be_pending
      end
    end

    context 'when user is the event host' do
      let(:user) { event.host.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the subscription' do
        expect(response.body).to equal_serialized(subscription.reload)
      end

      it 'confirms the subscription' do
        expect(subscription.reload).to be_confirmed
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
