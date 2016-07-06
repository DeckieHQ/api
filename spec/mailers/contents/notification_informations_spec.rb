require 'rails_helper'

RSpec.describe NotificationInformations do
  let(:notification) { FactoryGirl.create(:notification) }

  subject(:content) { described_class.new(notification) }

  describe '#description' do
    subject { content.description }

    context 'when a notification directly addresses to the user' do
      let(:notification) { FactoryGirl.create(:notification, :direct) }

      it do
        is_expected.to eq(I18n.t(
          "mailer.notification_informations.description.#{notification.type}.address_directly",
          display_name: "<b>#{notification.action.actor.display_name}</b>",
          title:        "<b>#{notification.action.title}</b>"
        ))
      end
    end

    context 'when a notification came from another user' do
      let(:notification) { FactoryGirl.create(:notification) }

      it do
        is_expected.to eq(I18n.t(
          "mailer.notification_informations.description.#{notification.type}.third_person",
          display_name: "<b>#{notification.action.actor.display_name}</b>",
          title:        "<b>#{notification.action.title}</b>"
        ))
      end
    end
  end

  describe '#url' do
    subject(:url) { content.url }

    it do
      is_expected.to equal_front_url_with("notification/#{notification.id}")
    end
  end
end
