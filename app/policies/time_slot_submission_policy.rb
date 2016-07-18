class TimeSlotSubmissionPolicy < ApplicationPolicy
  alias_method :time_slot_submission, :record

  def show?
    time_slot_submission_owner?
  end

  def destroy?
    time_slot_submission_owner?
  end

  private

  def time_slot_submission_owner?
    user.profile == time_slot_submission.profile
  end
end
