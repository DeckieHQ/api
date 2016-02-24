class EventsController < ApplicationController
  def show
    render json: event
  end

  protected

  def event
    @event ||= Event.find(params[:id])
  end
end
