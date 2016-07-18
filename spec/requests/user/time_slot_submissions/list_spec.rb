require 'rails_helper'

RSpec.describe 'List user time slot submissions', :type => :request do
  let(:params) {}

  before do
    get user_time_slot_submissions_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user, :with_time_slot_submissions) }

    let(:authenticate) { user }

    it_behaves_like 'an action with pagination', :user, :time_slot_submissions

    it_behaves_like 'an action with sorting', :user, :time_slot_submissions,
      accept: ['created_at', 'time_slot.begin_at']

    it_behaves_like 'an action with include', :user, :time_slot_submissions,
      accept: %w(time_slot time_slot.event)
  end
end
