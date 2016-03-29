class SubmissionPolicy < ApplicationPolicy
  include PolicyMatchers::Event

  alias_method :submission, :record

  delegate :event, to: :submission

  def show?
    submission_owner? || event_host?
  end

  def confirm?
    event_host? && !submission_already_confirmed? && !event_closed? && !event_full?
  end

  def destroy?
    submission_owner? && !event_closed?
  end

  private

  def submission_owner?
    user.profile == submission.profile
  end

  def submission_already_confirmed?
    add_error(:submission_already_confirmed) if submission.confirmed?
  end
end
