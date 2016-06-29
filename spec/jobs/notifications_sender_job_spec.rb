require 'rails_helper'

RSpec.describe NotificationsSenderJob, :type => :job do
  it 'uses the scheduler queue' do
    expect(described_class.queue_name).to eq('scheduler')
  end

  describe '#perform' do
    subject(:perform) { described_class.perform_now }

    let!(:users) do
      FactoryGirl.create_list(:user, 5, :with_notifications, :with_random_subscriptions)
    end

    let(:receivers) { User.select { |u| u.notifications_to_send.count > 0 } }

    let!(:expected_mails) do
      receivers.map do |user|
        UserMailer.notifications_informations(user, user.notifications_to_send).message
      end
    end

    before do
      MailDeliveries.clear

      perform
    end

    it 'sets sent to all the notifications' do
      expect(Notification.all.pluck(:sent)).to all( be_truthy )
    end

    it 'sends an email for each user notifications to send' do
      expect(MailDeliveries.all).to equal_mails(expected_mails)
    end
  end
end
