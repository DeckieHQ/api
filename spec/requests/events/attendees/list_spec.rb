require 'rails_helper'

RSpec.describe 'List event attendees', :type => :request do
  let(:event) { FactoryGirl.create(:event_with_attendees) }

  let(:params) {}

  before do
    get event_attendees_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action with pagination', :event, :attendees

  it_behaves_like 'an action with sorting', :event, :attendees, accept: %w(created_at)

  context "when event doesn't exist" do
    let(:event) { { event_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
