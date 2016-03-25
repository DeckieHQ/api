class ActionNotifier
  def initialize(action)
    @action = action
  end

  # TODO: send email here
  def notify
    Notification.transaction do
      action.resource.receivers_for(action).map do |receiver|
        unless receiver.deleted?
          Notification.create(action: action, user: receiver.user)
        end
      end
    end
  end

  private

  attr_reader :action
end
