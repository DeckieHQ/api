class User::NotificationsController < ApplicationController
  before_action :authenticate!

  def index
    search = Search.new(params, sort: %w(created_at), include: %w(action action.actor))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(current_user.notifications), include: search.included,
      meta: { remainings_count: current_user.notifications.remainings_count }
  end
end
