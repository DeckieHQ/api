require 'rails_helper'

RSpec.describe 'Show time slot submission', :type => :request do
  let(:time_slot_submission) { FactoryGirl.create(:time_slot_submission) }

  before do
    get time_slot_submission_path(time_slot_submission), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:authenticate) { user }

    context "when time slot submission doesn't exist" do
      let(:user) { FactoryGirl.create(:user) }

      let(:time_slot_submission) { { id: 0 } }

      it { is_expected.to return_not_found }
    end

    context 'when user has no access to the time slot submission' do
      let(:user) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }
    end

    context 'when time slot submissions belongs to the user' do
      let(:user) { time_slot_submission.profile.user }

      it { is_expected.to return_status_code 200 }

      it 'returns the time slot submission' do
        expect(response.body).to equal_serialized(time_slot_submission)
      end
    end
  end
end
