require 'rails_helper'

RSpec.shared_examples 'confirms and return the submission' do
  it { is_expected.to return_status_code 200 }

  it 'returns the submission' do
    expect(response.body).to equal_serialized(submission.reload)
  end

  it 'confirms the submission' do
    expect(submission.reload).to be_confirmed
  end

  it do
    is_expected.to have_created_action(submission.profile, submission.event, 'join')
  end
end

RSpec.describe 'Confirm event submission', :type => :request do
  let(:submission) { FactoryGirl.create(:submission, :pending) }

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
      let(:user) { submission.event.host.user }

      context 'when submission event is closed' do
        let(:submission) { FactoryGirl.create(:submission, :pending, :to_event_closed) }

        it { is_expected.to return_authorization_error(:event_closed) }

        it "doesn't confirm the submission" do
          expect(submission.reload).to be_pending
        end
      end

      context 'when event is not full after confirmation' do
        include_examples 'confirms and return the submission'
      end

      context 'when event is full after confirmation' do
        let(:submission) do
          FactoryGirl.create(:submission, :pending, :to_event_with_one_slot_remaining)
        end

        include_examples 'confirms and return the submission'
      end

      context 'when event is just ready after confirmation' do
        let(:submission) do
          FactoryGirl.create(:submission, :pending, :to_event_almost_ready)
        end

        include_examples 'confirms and return the submission'

        it do
          is_expected.to have_created_action(submission.profile, submission.event, 'ready')
        end
      end

      context 'when event is not ready after confirmation' do
        let(:submission) do
          FactoryGirl.create(:submission, :pending, :to_event_not_ready)
        end

        include_examples 'confirms and return the submission'

        it do
          is_expected.to_not have_created_action(submission.profile, submission.event, 'ready')
        end
      end

      context 'when event was already ready before confirmation' do
        let(:submission) do
          FactoryGirl.create(:submission, :pending, :to_event_ready)
        end

        include_examples 'confirms and return the submission'

        it do
          is_expected.to_not have_created_action(submission.profile, submission.event, 'ready')
        end
      end
    end
  end
end
