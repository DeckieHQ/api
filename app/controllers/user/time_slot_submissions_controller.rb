class User::TimeSlotSubmissionsController < ApplicationController
  before_action :authenticate!

  def index
    search = Search.new(params,
      sort: %w(created_at time_slot.begin_at), include: %w(time_slot time_slot.event)
    )
    return render_search_errors(search) unless search.valid?

    render json: search.apply(current_user.time_slot_submissions), include: search.included
  end
end
