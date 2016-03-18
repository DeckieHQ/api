class NotificationsController < ApplicationController
  before_action :authenticate!

  def show
    authorize notification

    included = Include.new(params[:include], accept: %w(action))

    return render_include_errors(included) unless included.valid?

    render json: notification, include: included.params
  end

  def view
    authorize notification

    render json: notification.tap(&:viewed!)
  end

  protected

  def notification
    @notification ||= Notification.find(params[:id])
  end
end
