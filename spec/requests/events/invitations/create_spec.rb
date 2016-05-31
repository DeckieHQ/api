require 'rails_helper'

RSpec.describe 'Create event invitation', :type => :request do
  let(:params) { Serialize.params(invitation_params, type: :invitations) }

  let(:invitation_params) { invitation.attributes }

  let(:invitation) { FactoryGirl.build(:invitation) }

  let(:event) { FactoryGirl.create(:event) }

  before do
    post event_invitations_path(event), params: params, headers: json_headers
  end

  after { MailDeliveries.clear }

  it_behaves_like 'an action requiring authentication'

  context 'when user is authenticated' do
    context 'as the event host' do
      let(:authenticate) { event.host.user }

      let(:created_invitation) do
        event.invitations.find_by(sender: authenticate.profile)
      end

      it { is_expected.to return_status_code 201 }

      it 'creates a new event invitation with permited parameters' do
        permited_params = invitation.slice(:email, :message)

        expect(created_invitation).to have_attributes(permited_params)
      end

      it 'returns the invitation created' do
        expect(response.body).to equal_serialized(created_invitation)
      end

      it { is_expected.to have_sent_mail }

      context 'when event is closed' do
        let(:event) { FactoryGirl.create(:event_closed) }

        it { is_expected.to return_authorization_error(:event_closed) }

        it { is_expected.to_not have_sent_mail }
      end

      context 'when invitation is invalid' do
        let(:invitation) { FactoryGirl.build(:invitation, :with_invalid_email) }

        it { is_expected.to return_validation_errors :invitation }

        it { is_expected.to_not have_sent_mail }
      end
    end

    context 'as another user' do
      let(:authenticate) { FactoryGirl.create(:user) }

      it { is_expected.to return_forbidden }

      it { is_expected.to_not have_sent_mail }
    end

    context "when event doesn't exist" do
      let(:authenticate) { FactoryGirl.create(:user) }

      let(:event) { { event_id: 0 } }

      it { is_expected.to return_not_found }

      it { is_expected.to_not have_sent_mail }
    end
  end
end
