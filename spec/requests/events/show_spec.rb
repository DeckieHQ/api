require 'rails_helper'

RSpec.describe 'Event show', :type => :request do
  let(:event) { FactoryGirl.create(:event) }

  let(:params) {}

  before do
    get event_path(event), params: params, headers: json_headers
  end

  it { is_expected.to return_status_code 200 }

  it 'returns the event attributes' do
    expect(response.body).to equal_serialized(event)
  end

  it_behaves_like 'an action with include', :event,
    accept: %w(host), on: :member

  context "when event doesn't exist" do
    let(:event) { { id: 0 } }

    it { is_expected.to return_not_found }
  end
end
