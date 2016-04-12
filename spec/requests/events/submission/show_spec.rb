require 'rails_helper'

RSpec.describe 'Submission show', :type => :request do
  let(:event) { FactoryGirl.create(:event_with_submissions) }

  let(:params) {}

  before do
    get event_submission_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'user has a submission on the event' do
    let(:submission)   { event.submissions.last }
    let(:authenticate) { submission.profile.user }

    it { is_expected.to return_status_code 200 }

    it 'returns the submission attributes' do
      expect(response.body).to equal_serialized(submission)
    end
  end

  context "user hasn't a submission on the event" do
    let(:authenticate) { FactoryGirl.create(:user) }

    it { is_expected.to return_status_code 200 }

    it 'returns the submission attributes' do
      expect(response.body).to eq("null")
    end
  end

  context "when event doesn't exist" do
    let(:authenticate) { FactoryGirl.create(:user) }
    let(:event) { { event_id: 0 } }

    it { is_expected.to return_not_found }
  end
end
