require 'rails_helper'

RSpec.describe 'List user subscriptions', :type => :request do
  let(:params) {}

  before do
    get user_subscriptions_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user, :with_subscriptions) }

    let(:authenticate) { user }

  #  it_behaves_like 'an action with pagination', :user, :subscriptions

    #it_behaves_like 'an action with sorting', :user, :subscriptions,
    #  accept: ['event.begin_at']

    it_behaves_like 'an action with filtering', :user, :subscriptions,
      accept: { scopes: [:status], associations_scopes: { event: [:opened] } },
      try: {
        status: [:confirmed, :pending, :unknown],
        event:  [{ opened: true }, { opened: false}]
      }
  end
end
