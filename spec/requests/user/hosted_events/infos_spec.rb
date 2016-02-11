require 'rails_helper'

RSpec.describe 'User hosted events infos', :type => :request do
  let(:event) { FactoryGirl.create(:event) }

  before do
    get user_hosted_event_path(event), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)         { FactoryGirl.create(:user) }
    let(:authenticate) { user }

    context 'when event belongs to the user' do
      let(:event) do
        FactoryGirl.build(:event).tap do |event|
          user.hosted_events << event
        end
      end

      it { is_expected.to return_status_code 200 }

      it 'returns the event attributes' do
        expect(response.body).to equal_serialized(event)
      end
    end

    context "when event doesn't belong to the user" do
      it { is_expected.to return_not_found }
    end
  end
end
