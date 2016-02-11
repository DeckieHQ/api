require 'rails_helper'

RSpec.describe 'User hosted event show', :type => :request do
  let(:event) { FactoryGirl.create(:event_with_host) }

  before do
    get user_hosted_event_path(event), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'when event belongs to the user' do
      let(:authenticate) { event.host.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the event attributes' do
        expect(response.body).to equal_serialized(event)
      end
    end

    context "when event doesn't belong to the user" do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_not_found }
    end
  end
end
