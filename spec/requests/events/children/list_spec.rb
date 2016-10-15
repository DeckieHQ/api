require 'rails_helper'

RSpec.describe 'List event children', :type => :request do
  let(:event) { FactoryGirl.create(:event, :recurrent) }

  let(:params) {}

  before do
    get event_children_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action with pagination', :event, :children

  it_behaves_like 'an action with sorting', :event, :children, accept: %w(begin_at)

  context "when event doesn't exist" do
    let(:event) { { event_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
