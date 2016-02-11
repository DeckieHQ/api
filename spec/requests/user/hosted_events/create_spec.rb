require 'rails_helper'

RSpec.describe 'User create hosted event', :type => :request do
  let(:params)       { Serialize.params(event_params, type: :events) }
  let(:event_params) { event.attributes }

  before do
    post user_hosted_events_path, params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:authenticate) { user }

    it_behaves_like 'an action requiring verification'

    context 'when user is verified' do
      let(:user) { FactoryGirl.create(:user_verified) }

      include_examples 'check parameters for', :events

      context 'when attributes are valid' do
        let(:event) { FactoryGirl.build(:event) }

        let(:created_event) { user.hosted_events.last }

        it { is_expected.to return_status_code 201 }

        it 'creates a new hosted event with permited parameters' do
          permited_params = event.slice(
            :title, :category, :ambiance, :level, :capacity, :invite_only,
            :description, :street, :postcode, :city, :state, :country
          )
          expect(created_event).to have_attributes(permited_params)

          expect(created_event.begin_at).to equal_time(event.begin_at)
          expect(created_event.end_at).to   equal_time(event.end_at)
        end

        it 'returns the event attributes' do
          expect(response.body).to equal_serialized(created_event)
        end
      end

      context 'when attributes are invalid' do
        let(:event) { Event.new }

        it { is_expected.to return_validation_errors :event }
      end
    end
  end
end
