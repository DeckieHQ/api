require 'rails_helper'

RSpec.describe 'Event delete', :type => :request do
  let(:event) { FactoryGirl.create(:event) }

  before do
    delete event_path(event), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'when event belongs to the user' do
      let(:authenticate) { event.host.user }

      it { is_expected.to return_status_code 204 }

      it 'deletes the event' do
        expect(Event.find_by(id: event.id)).to be_nil
      end

      it { is_expected.to have_created_action(authenticate, event, 'cancel') }

      context 'when event is closed' do
        let(:event) { FactoryGirl.create(:event_closed) }

        it { is_expected.to return_authorization_error(:event_closed) }

        it "doesn't delete the event" do
          expect(event.reload).to be_persisted
        end
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

      it "doesn't destroy the event" do
        expect(event.reload).to be_persisted
      end
    end
  end
end
