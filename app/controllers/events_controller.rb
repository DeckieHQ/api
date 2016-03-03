class EventsController < ApplicationController
  before_action :authenticate!, only: [:update, :destroy]

  def show
    render json: event
  end

  def update
    authorize event

    unless event_service.update(event_params)
      return render_validation_errors(event_service)
    end
    render json: event
  end

  def destroy
    authorize event

    unless event_service.destroy
      return render_validation_errors(event_service)
    end
    head :no_content
  end

  protected

  def event
    @event ||= Event.find(params[:id])
  end

  def event_service
    @event_service ||= EventService.new(event)
  end

  def event_params
    attributes(:events).permit(policy(event).permited_attributes)
  end
end
