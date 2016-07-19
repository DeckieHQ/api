require 'rails_helper'

RSpec.describe 'Create time slot submission', :type => :request do
  let(:time_slot) { FactoryGirl.create(:time_slot) }

  before do
    post time_slot_time_slot_submissions_path(time_slot), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user) { FactoryGirl.create(:user) }

    let(:authenticate) { user }

    let(:created_time_slot_submission) do
      time_slot.time_slot_submissions.find_by(profile_id: user.profile.id)
    end

    it { is_expected.to return_status_code 201 }

    it 'returns the time slot submission created' do
      expect(response.body).to equal_serialized(created_time_slot_submission)
    end

    context 'when authenticated as the time slot event host' do
      let(:authenticate) { time_slot.event.host.user }

      it { is_expected.to return_forbidden }

      it "doesn't create a time slot submission" do
        expect(created_time_slot_submission).to_not be_present
      end
    end

    context "when time slot doesn't exist" do
      let(:time_slot) { { time_slot_id: 0 } }

      it { is_expected.to return_not_found }
    end
  end
end
