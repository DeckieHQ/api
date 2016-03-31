require 'rails_helper'

RSpec.describe 'Event update', :type => :request do
  let(:params) { Serialize.params(event_update_params, type: :events) }

  let(:event)               { FactoryGirl.create(:event) }
  let(:event_update)        { FactoryGirl.build(:event)  }
  let(:event_update_params) { event_update.attributes }

  let(:permited_params) do
    event_update.slice(
      :title, :category, :ambiance, :level, :capacity, :auto_accept,
      :description, :street, :postcode, :city, :state, :country
    )
  end

  before do
    put event_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'when event belongs to the user' do
      let(:authenticate) { event.host.user }

      before { event.reload }

      include_examples 'check parameters for', :events

      it { is_expected.to return_status_code 200 }

      it 'returns the event attributes' do
        expect(response.body).to equal_serialized(event)
      end

      it 'updates the event with permited params' do
        expect(event).to have_attributes(permited_params)

        expect(event.begin_at).to equal_time(event_update.begin_at)
        expect(event.end_at).to   equal_time(event_update.end_at)
      end

      it { is_expected.to have_created_action(authenticate.profile, event, 'update') }

      context 'when switching to auto accept' do
        let(:event) { FactoryGirl.create(:event_with_submissions) }

        let(:event_update) { FactoryGirl.build(:event, :auto_accept) }

        it 'confirms the maximum confirmable submissions' do
          event.submissions.all do |submissions|
            expect(submission).to be_confirmed
          end
        end

        it { is_expected.to have_many_actions(event.submissions.map(&:profile), event, 'join') }
      end

      context 'when attributes are invalid' do
        let(:event_update) { Event.new }

        it { is_expected.to return_validation_errors :event_update }

        it { is_expected.to_not have_created_action }
      end

      context 'when event is closed' do
        let(:event) { FactoryGirl.create(:event_closed) }

        it { is_expected.to return_authorization_error(:event_closed) }
      end
    end

    context "when event doesn't exists" do
      let(:event) { { id: 0 } }

      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_not_found }
    end

    context "when event doesn't belong to the user" do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it "doesn't update the event" do
        expect(event).to_not have_been_changed
      end
    end
  end
end
