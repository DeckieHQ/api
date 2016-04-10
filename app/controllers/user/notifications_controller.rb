class User::NotificationsController < ApplicationController
  before_action :authenticate!

  def index
    search = Search.new(params, sort: %w(action.created_at), include: %w(action action.actor))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(current_user.notifications), include: search.included
  end

  def reset_count
    render json: current_user.tap(&:reset_notifications_count!)
  end
end
