require 'rails_helper'

RSpec.describe 'Event update', :type => :request do
  let(:params) { Serialize.params(event_update_params, type: :events) }

  let(:event_update_params) { event_update.attributes }

  let(:event_update) { FactoryGirl.build(:event)  }

  let(:event) { FactoryGirl.create(:event) }

  before do
    put event_path(event), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'when event belongs to the user' do
      let(:authenticate) { event.host.user }

      before do
        event.reload
      end

      include_examples 'check parameters for', :events

      it { is_expected.to return_status_code 200 }

      it 'returns the event attributes' do
        expect(response.body).to equal_serialized(event)
      end

      it 'updates the event with permited params' do
        permited_params = event_update.slice(
          :title, :category, :ambiance, :level, :capacity, :auto_accept,
          :description, :street, :postcode, :city, :state, :country
        )
        expect(event).to have_attributes(permited_params)

        expect(event.begin_at).to equal_time(event_update.begin_at)
        expect(event.end_at).to   equal_time(event_update.end_at)
      end

      context 'when attributes are invalid' do
        let(:event_update) { Event.new }

        it { is_expected.to return_validation_errors :event_update }
      end

      context 'when event is closed' do
        let(:event) { FactoryGirl.create(:event_closed) }

        it { is_expected.to return_forbidden }
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
    end
  end
end
