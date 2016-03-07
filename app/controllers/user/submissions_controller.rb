class User::SubmissionsController < ApplicationController
  before_action :authenticate!

  def index
    search = Search.new(params, sort: %w(created_at event.begin_at), include: %w(event),
      filters: { scopes: [:status], associations_scopes: { event: [:opened] } }
    )
    return render_search_errors(search) unless search.valid?

    render json: search.apply(current_user.submissions), include: search.included
  end
end
