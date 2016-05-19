require 'rails_helper'

RSpec.describe 'Contact show', :type => :request do
  let(:contact) { Contact.new(FactoryGirl.create(:user_with_hosted_events)) }

  let(:params) {}

  before do
    get contact_path(contact.id), params: params, headers: json_headers
  end

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    let(:authenticate) { FactoryGirl.create(:user) }

    it { is_expected.to return_forbidden }

    context 'when user has access to the contact' do
      let(:authenticate) do
        FactoryGirl.create(:user) do |user|
          event = contact.user.hosted_events.sample

          event.update(auto_accept: true)

          JoinEvent.new(user.profile, event).call
        end
      end

      it { is_expected.to return_status_code 200 }

      it 'returns the submission attributes' do
        expect(response.body).to equal_serialized(contact)
      end
    end

    context "when contact doesn't exist" do
      let(:contact) { Struct.new(:id).new(id: 0) }

      it { is_expected.to return_not_found }
    end
  end
end
