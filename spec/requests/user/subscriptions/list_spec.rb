require 'rails_helper'

RSpec.describe 'List user submissions', :type => :request do
  let(:params) {}

  before do
    get user_submissions_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user, :with_submissions) }

    let(:authenticate) { user }

    it_behaves_like 'an action with pagination', :user, :submissions

    it_behaves_like 'an action with sorting', :user, :submissions,
      accept: ['created_at', 'event.begin_at']

    it_behaves_like 'an action with filtering', :user, :submissions,
      accept: { scopes: [:status], associations_scopes: { event: [:opened] } },
      try: {
        status: [:confirmed, :pending, :unknown],
        event:  [{ opened: true }, { opened: false}]
      }

    it_behaves_like 'an action with include', :user, :submissions,
      accept: %w(event)
  end
end
