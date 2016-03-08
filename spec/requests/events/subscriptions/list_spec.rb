require 'rails_helper'

RSpec.describe 'List event submissions', :type => :request do
  let(:event) { FactoryGirl.create(:event_with_submissions) }

  let(:params) {}

  before do
    get event_submissions_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:authenticate) { user }

    context 'when user is not the event host' do
      let(:user) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }
    end

    context 'when user is the event host' do
      let(:user) { event.host.user }

      it_behaves_like 'an action with pagination', :event, :submissions

      it_behaves_like 'an action with sorting', :event, :submissions,
        accept: %w(created_at)

      it_behaves_like 'an action with filtering', :event, :submissions,
        accept: { scopes: [:status] }, try: { status: %w(confirmed pending unknown) }

      it_behaves_like 'an action with include', :event, :submissions,
        accept: %w(profile)
    end

    context "when event doesn't exist" do
      let(:user) { FactoryGirl.create(:user) }

      let(:event) { { event_id: 0 } }

      it { is_expected.to return_not_found }
    end
  end
end
