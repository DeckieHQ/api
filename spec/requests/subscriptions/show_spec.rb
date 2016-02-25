require 'rails_helper'

RSpec.describe 'Show event subscription', :type => :request do
  let(:event) { FactoryGirl.create(:event, :with_pending_subscriptions) }

  let(:subscription) { event.subscriptions.shuffle.last }

  before do
    get subscription_path(subscription), headers: json_headers
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
    end

    context 'when user is the event host' do
      let(:user) { event.host.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the subscription' do
        expect(response.body).to equal_serialized(subscription)
      end
    end

    context 'when subscribtion belongs to the user' do
      let(:user) { subscription.profile.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the subscription' do
        expect(response.body).to equal_serialized(subscription)
      end
    end
  end
end
