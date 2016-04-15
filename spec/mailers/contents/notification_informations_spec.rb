require 'rails_helper'

RSpec.describe NotificationInformations do
  let(:notification) { FactoryGirl.create(:notification) }

  subject(:content) { described_class.new(notification) }

  describe '#username' do
    subject(:username) { content.username }

    it { is_expected.to eq(notification.user.email) }
  end

  describe '#subject' do
    subject { content.subject }

    context 'when a notification directly addresses to the user' do
      let(:notification) { FactoryGirl.create(:notification, :direct) }

      it do
        is_expected.to eq(I18n.t(
          "mailer.notification_informations.subject.#{notification.type}.address_directly",
          display_name: notification.action.actor.display_name
        ))
      end
    end

    context 'when a notification came from another user' do
      let(:notification) { FactoryGirl.create(:notification) }

      it do
        is_expected.to eq(I18n.t(
          "mailer.notification_informations.subject.#{notification.type}.third_person",
          display_name: notification.action.actor.display_name
        ))
      end
    end
  end

  describe '#description' do
    subject { content.description }

    context 'when a notification directly addresses to the user' do
      let(:notification) { FactoryGirl.create(:notification, :direct) }

      it do
        is_expected.to eq(I18n.t(
          "mailer.notification_informations.description.#{notification.type}.address_directly",
          display_name: notification.action.actor.display_name, title: notification.action.title
        ))
      end
    end

    context 'when a notification came from another user' do
      let(:notification) { FactoryGirl.create(:notification) }

      it do
        is_expected.to eq(I18n.t(
          "mailer.notification_informations.description.#{notification.type}.third_person",
          display_name: notification.action.actor.display_name, title: notification.action.title
        ))
      end
    end
  end

  describe '#notification_url' do
    subject(:notification_url) { content.notification_url }

    it do
      is_expected.to equal_front_url_with("notifications/#{notification.id}")
    end
  end
end
