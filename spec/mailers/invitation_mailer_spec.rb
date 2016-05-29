require 'rails_helper'

RSpec.describe InvitationMailer do
  let(:invitation) { FactoryGirl.create(:invitation)  }

  let(:culture) { invitation.user.culture }

  describe '#informations' do
    let(:mail) do
      described_class.informations(invitation)
    end

    let(:content) do
      I18n.locale = culture

      InvitationInformations.new(invitation)
    end

    it_behaves_like 'a mail with', :invitation_informations, to: :invitation,
      greets_user: true,
      labels:      [:link],
      attributes:  [:details, :invitation_url, :message]
  end
end
