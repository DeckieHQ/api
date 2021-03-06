require 'rails_helper'

RSpec.describe 'List event comments', :type => :request do
  let(:event) { FactoryGirl.create(:event, :with_comments) }

  let(:params) {}

  before do
    get event_comments_path(event), params: params, headers: json_headers
  end

  context "when user is an event's member" do
    let(:authenticate) { event.host.user }

    it_behaves_like 'an action with pagination', :event, :comments

    it_behaves_like 'an action with sorting', :event, :comments, accept: %w(created_at)

    it_behaves_like 'an action with filtering', :event, :comments,
      accept: { scopes: [:privates] }, try: { privates: [true, false, nil, 1, 0] }

    it_behaves_like 'an action with include', :event, :comments, accept: %w(author)
  end

  context "when user isn't an event's member" do
    it_behaves_like 'an action with pagination', :event, :public_comments

    it_behaves_like 'an action with sorting', :event, :public_comments, accept: %w(created_at)

    it_behaves_like 'an action with filtering', :event, :public_comments, accept: {}

    it_behaves_like 'an action with include', :event, :public_comments, accept: %w(author)
  end

  context "when event doesn't exist" do
    let(:event) { { event_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
