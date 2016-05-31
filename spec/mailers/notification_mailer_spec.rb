require 'rails_helper'

RSpec.describe NotificationMailer do
  let(:notification) { FactoryGirl.create(:notification)  }

  let(:user) { notification.user }

  let(:culture) { user.culture }

  describe '#informations' do
    let(:mail) { described_class.informations(notification) }

    let(:content) do
      I18n.locale = culture

      NotificationInformations.new(notification)
    end

    it_behaves_like 'a mail with', :notification_informations,
      greets_user: true,
      labels:      [:details,     :link],
      attributes:  [:description, :notification_url]
  end
end
