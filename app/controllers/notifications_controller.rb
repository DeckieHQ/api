class NotificationsController < ApplicationController
  before_action :authenticate!

  def show
    authorize notification

    render json: notification
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
