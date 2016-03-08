require 'rails_helper'

RSpec.describe 'Confirm event submission', :type => :request do
  let(:event) { FactoryGirl.create(:event, :with_pending_submissions) }

  let(:submission) { event.submissions.shuffle.last }

  before do
    post confirm_submission_path(submission), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:authenticate) { user }

    context "when submission doesn't exist" do
      let(:user) { FactoryGirl.create(:user) }

      let(:submission) { { id: 0 } }

      it { is_expected.to return_not_found }
    end

    context 'when user has no access to the submission' do
      let(:user) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it "doesn't confirm the submission" do
        expect(submission.reload).to be_pending
      end
    end

    context 'when user is the event host' do
      let(:user) { event.host.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the submission' do
        expect(response.body).to equal_serialized(submission.reload)
      end

      it 'confirms the submission' do
        expect(submission.reload).to be_confirmed
      end

      # Test the service invokation. Therefore we don't need more tests here as
      # the service is heavily tested independantly.
      context 'when event is closed' do
        let(:event) { FactoryGirl.create(:event_closed, :with_pending_submissions) }

        it { is_expected.to return_authorization_error(:event_closed) }
      end
    end
  end
end
