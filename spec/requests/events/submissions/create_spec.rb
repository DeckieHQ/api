require 'rails_helper'

RSpec.describe 'Create event submission', :type => :request do
  let(:event) { FactoryGirl.create(:event) }

  before do
    post event_submissions_path(event), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user) }

    let(:authenticate) { user }

    let(:created_submission) { event.submissions.last }

    it { is_expected.to return_status_code 201 }

    it 'subscribes the user with a pending status' do
      expect(created_submission).to have_attributes(
        profile_id: user.profile.id, status: 'pending'
      )
    end

    it 'returns the submission created' do
      expect(response.body).to equal_serialized(created_submission)
    end

    it { is_expected.to have_created_action(user, event, 'subscribe') }

    context 'when event has auto_accept' do
      let(:event) { FactoryGirl.create(:event, :auto_accept) }

      it 'subscribes the user with a confirmed status' do
        expect(created_submission).to have_attributes(
          profile_id: user.profile.id, status: 'confirmed'
        )
      end

      it { is_expected.to have_created_action(user, event, 'join') }
    end

    context 'when event is closed' do
      let(:event) { FactoryGirl.create(:event_closed) }

      it { is_expected.to return_authorization_error(:event_closed) }
    end

    context 'when authenticated as the event host' do
      let(:authenticate) { event.host.user }

      it { is_expected.to return_forbidden }
    end

    context "when event doesn't exist" do
      let(:event) { { event_id: 0 } }

      it { is_expected.to return_not_found }
    end
  end
end
