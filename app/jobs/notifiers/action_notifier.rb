class ActionNotifier
  def initialize(action)
    @action = action
  end

  def notify
    action.resource.receivers_for(action).map do |receiver|
      unless receiver.deleted?
        Notification.create(action: action, user: receiver.user)

        # TODO: send email here
      end
    end
  end

  private

  attr_reader :action
end
