class EventsController < ApplicationController
  before_action :authenticate!, only: [:update, :destroy]

  def show
    included = Include.new(params[:include], accept: %w(host))

    return render_include_errors(included) unless included.valid?

    render json: event, include: included.params
  end

  def update
    authorize event

    result = ChangeEventInfos.new(current_user.profile, event).call(event_params)

    if result.errors.present?
      return render_validation_errors(result)
    end
    render json: result
  end

  def destroy
    authorize event

    CancelEvent.new(current_user.profile, event).call

    head :no_content
  end

  protected

  def event
    @event ||= Event.find(params[:id])
  end

  def event_params
    attributes(:events).permit(policy(event).permited_attributes)
  end
end
