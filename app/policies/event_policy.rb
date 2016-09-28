class EventPolicy < ApplicationPolicy
  include PolicyMatchers::User
  include PolicyMatchers::Event

  alias_method :event, :record

  # Currently not used (we are waiting to have more users)
  def create?
    user_verified?
  end

  def update?
    (user.moderator? ||event_host?) && !event_closed?
  end

  def destroy?
    update?
  end

  def submit?
    !event_host? && !submission_already_exist? && !event_closed? && !event_full? &&
    !event_flexible? && !event_recurrent?
  end

  def submissions?
    event_host?
  end

  def permited_attributes_for_create
    permited_attributes_for_update.concat([:flexible, new_time_slots: []])
  end

  def permited_attributes_for_update
    [
      :title,
      :category,
      :ambiance,
      :level,
      :capacity,
      :min_capacity,
      :auto_accept,
      :short_description,
      :description,
      :begin_at,
      :end_at,
      :street,
      :postcode,
      :city,
      :state,
      :country,
      :private,
      :unlimited_capacity
    ]
  end

  private

  def submission_already_exist?
    event.submissions.find_by(profile: user.profile)
  end
end
