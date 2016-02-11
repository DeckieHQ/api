require 'rails_helper'

RSpec.describe 'User hosted event delete', :type => :request do
  let(:event) { FactoryGirl.create(:event) }

  before do
    delete user_hosted_event_path(event), headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:user)         { FactoryGirl.create(:user) }
    let(:authenticate) { user }

    context 'when event belongs to the user' do
      let(:event) do
        FactoryGirl.build(:event).tap do |event|
          user.hosted_events << event
        end
      end

      it { is_expected.to return_status_code 204 }

      it 'deletes the event' do
        expect(Event.find_by(id: event.id)).to be_nil
      end

      context 'when event is already started' do
        let(:event) do
          FactoryGirl.build(:event).tap do |event|
            user.hosted_events << event

            event.begin_at = 2.days.ago

            event.save(validate: false)

            event.errors.add(:base, :already_started)
          end
        end

        it { is_expected.to return_validation_errors :event }

        it "doesn't delete the event" do
          expect(event.reload).to be_persisted
        end
      end
    end

    context "when event doesn't belong to the user" do
      it { is_expected.to return_not_found }
    end
  end
end
