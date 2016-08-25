class RemindFlexibleEvents < ApplicationJob
  EMAIL_TYPE = :flexible_event_reminder

  queue_as :scheduler

  def perform
    Event.confirmable_in(percentage: 40).each do |event|
      receiver = event.host.user

      unless receiver.received_email?(EMAIL_TYPE, event)
        receiver.deliver_email(EMAIL_TYPE, event)
      end
    end
  end
end
