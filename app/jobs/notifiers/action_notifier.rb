class ActionNotifier
  def initialize(action)
    @action = action
  end

  # TODO: A tester si le profile est deleted que ça plante pas
  def notify
    Notification.transaction do
      User.where(profile_id: action.receiver_ids).map do |user|
        Notification.create(action: action, user: user)
      end
    end
  end

  private

  attr_reader :action
end
