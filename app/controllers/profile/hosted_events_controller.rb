class Profile::HostedEventsController < ApplicationController
  def index
    search = Search.new(
      params, sort: %w(begin_at end_at), filters: { scopes: [:opened, :type] }
    )
    return render_search_errors(search) unless search.valid?

    render json: search.apply(profile.hosted_events)
  end

  protected

  def profile
    @profile ||= Profile.find(params[:profile_id])
  end
end
