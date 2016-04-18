class Event::SubmissionsController < ApplicationController
  before_action :authenticate!, only: [:show]

  def show
    render json: event.submission_of(current_user) || { data: nil }
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end
end
