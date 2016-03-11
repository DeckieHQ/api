require 'rails_helper'

RSpec.describe 'Show event submission', :type => :request do
  let(:event) { FactoryGirl.create(:event, :with_pending_submissions) }

  let(:submission) { event.submissions.shuffle.last }

  before do
    get submission_path(submission), headers: json_headers
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
    end

    context 'when user is the event host' do
      let(:user) { event.host.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the submission' do
        expect(response.body).to equal_serialized(submission)
      end
    end

    context 'when subscribtion belongs to the user' do
      let(:user) { submission.profile.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the submission' do
        expect(response.body).to equal_serialized(submission)
      end
    end
  end
end
