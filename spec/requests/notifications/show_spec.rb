require 'rails_helper'

RSpec.describe 'Show notification', :type => :request do
  let(:notification) { FactoryGirl.create(:notification) }

  before do
    get notification_path(notification), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:authenticate) { user }

    context "when notification doesn't exist" do
      let(:user) { FactoryGirl.create(:user) }

      let(:notification) { { id: 0 } }

      it { is_expected.to return_not_found }
    end

    context 'when user has no access to the notification' do
      let(:user) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }
    end

    context 'when user is the notification owner' do
      let(:user) { notification.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the notification' do
        expect(response.body).to equal_serialized(notification)
      end
    end
  end
end
