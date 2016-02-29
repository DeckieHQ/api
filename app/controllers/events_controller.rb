class EventsController < ApplicationController
  before_action :authenticate!, only: [:update, :destroy]

  before_action -> { check_parameters_for(:events) }, only: :update

  def show
    render json: event
  end

  def update
    return render_error_for(:forbidden) unless event_host?

    unless event_service.update(event_params)
      return render_validation_errors(event_service)
    end
    render json: event
  end

  def destroy
    return render_error_for(:forbidden) unless event_host?

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

  def event_host?
    current_profile == event.host
  end

  def event_params
    resource_attributes.permit(
     :title, :category, :ambiance, :level, :capacity, :auto_accept, :description,
     :begin_at, :end_at, :street, :postcode, :city, :state, :country
    )
  end
end
