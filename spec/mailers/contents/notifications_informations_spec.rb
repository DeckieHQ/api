require 'rails_helper'

RSpec.describe NotificationsInformations do
  let(:notifications) { FactoryGirl.create_list(:notification, 5) }

  let(:user) { notifications.first.user }

  subject(:content) { described_class.new(user, notifications) }

  describe '#username' do
    subject(:username) { content.username }

    it { is_expected.to eq(user.email) }
  end

  describe '#subject' do
    subject { content.subject }

    it do
      is_expected.to eq(I18n.t('mailer.notifications_informations.subject'))
    end
  end

  describe '#notifications' do
    it 'is equal to notification informations of each notifications' do
      content.notifications.each do |n|
        expect(n.instance_values).to eq(NotificationInformations.new(n).instance_values)
      end
    end
  end
end
