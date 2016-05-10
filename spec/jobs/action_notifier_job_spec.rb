require 'rails_helper'

RSpec.describe ActionNotifierJob, :type => :job do
  it 'uses the notifications queue' do
    expect(described_class.queue_name).to eq('notifications')
  end

  describe '#perform' do
    subject(:perform) { described_class.perform_now(action) }

    # We must create an action without notifications, otherwise the job will
    # fail because of the unique index [action_id, user_id] on table notifications.
    let(:action) do
      FactoryGirl.create(:action, :of_event_with_submissions, notify: :never)
    end

    let(:receivers) do
      Profile.where(id: action.receivers_ids).includes(:user)
    end

    context 'when receivers exists' do
      before do
        subscribe_to_action(receivers.sample)

        perform
      end

      it 'creates notifications for this action' do
        receivers.each do |receiver|
          expect(notification_of(receiver.user)).to be_present
        end
      end

      it 'sends an email to each user who subscribed to the notification' do
        receivers.each do |receiver|
          user = receiver.user

          notification = notification_of(user)

          is_expected.public_send(
            user.subscribed_to?(notification) ? :to : :not_to,

            have_enqueued_notification_mail_for(notification)
          )
        end
      end

      def subscribe_to_action(profile)
        return unless profile

        notification_type = Notification.new(action: action).send(:set_type)

        profile.user.update(
          preferences: { notifications: [notification_type] }
        )
      end
    end

    context 'when receivers have been deleted' do
      before do
        receivers.destroy_all

        perform
      end

      it 'creates no notifications for this action' do
        expect(Notification.where(action_id: action.id)).to be_empty
      end
    end

    def notification_of(user)
      Notification.find_by!(user_id: user.id, action_id: action.id, viewed: false)
    end
  end
end
