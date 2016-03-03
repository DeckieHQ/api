require 'rails_helper'

RSpec.describe 'Create event subscription', :type => :request do
  let(:event) { FactoryGirl.create(:event) }

  before do
    post event_subscriptions_path(event), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user) }

    let(:authenticate) { user }

    let(:created_subscription) { event.subscriptions.last }

    it { is_expected.to return_status_code 201 }

    it 'subscribes the user with a pending status' do
      expect(created_subscription).to have_attributes(
        profile_id: user.profile.id, status: 'pending'
      )
    end

    it 'returns the subscription created' do
      expect(response.body).to equal_serialized(created_subscription)
    end

    context 'when event has auto_accept' do
      let(:event) { FactoryGirl.create(:event, :auto_accept) }

      it 'subscribes the user with a confirmed status' do
        expect(created_subscription).to have_attributes(
          profile_id: user.profile.id, status: 'confirmed'
        )
      end
    end

    context 'when event is closed' do
      let(:event) { FactoryGirl.create(:event_closed) }

      it { is_expected.to return_authorization_error(:event_closed) }
    end

    context 'when authenticated as the event host' do
      let(:authenticate) { event.host.user }

      it { is_expected.to return_forbidden }
    end

    context "when event doesn't exist" do
      let(:event) { { event_id: 0 } }

      it { is_expected.to return_not_found }
    end
  end
end
