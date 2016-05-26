class FeedbacksController < ApplicationController
  before_action :authenticate

  def create
    unless feedback.valid?
      return render_validation_errors(feedback)
    end
    feedback.send_informations
  end

  protected

  def feedback
    @feedback ||= Feedback.new(permited_attributes(Feedback))
  end
end
