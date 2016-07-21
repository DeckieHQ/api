require 'rails_helper'

RSpec.describe 'Delete time slot submission', :type => :request do
  let(:time_slot_submission) { FactoryGirl.create(:time_slot_submission) }

  before do
    delete time_slot_submission_path(time_slot_submission), headers: json_headers
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

      it do
        is_expected.to_not have_created_action(
          time_slot_submission.profile, time_slot_submission.time_slot, 'leave'
        )
      end
    end

    context 'when time slot submissions belongs to the user' do
      let(:user) { time_slot_submission.profile.user }

      it { is_expected.to return_status_code 204 }

      it 'deletes the time slot submission' do
        expect(TimeSlotSubmission.find_by(id: time_slot_submission.id)).to_not be_present
      end

      it do
        is_expected.to have_created_action(
          time_slot_submission.profile, time_slot_submission.time_slot, 'leave'
        )
      end
    end
  end
end
