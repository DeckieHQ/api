class Profile::TimeSlotSubmissionsController < ApplicationController
  def index
    search = Search.new(params,
      sort: %w(created_at time_slot.begin_at), include: %w(time_slot time_slot.event)
    )
    return render_search_errors(search) unless search.valid?

    render json: search.apply(profile.time_slot_submissions), include: search.included
  end

  protected

  def profile
    @profile ||= Profile.find(params[:profile_id])
  end
end
