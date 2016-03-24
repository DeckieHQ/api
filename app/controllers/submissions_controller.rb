class SubmissionsController < ApplicationController
  before_action :authenticate!

  def index
    authorize event, :submissions?

    search = Search.new(params,
      sort: %w(created_at), include: %w(profile), filters: { scopes: [:status] }
    )
    return render_search_errors(search) unless search.valid?

    render json: search.apply(event.submissions), include: search.included
  end

  def create
    authorize event, :subscribe?

    subscribtion = JoinEvent.new(current_user.profile, event).call

    render json: subscribtion, status: :created
  end

  def show
    authorize submission

    render json: submission
  end

  def confirm
    authorize submission

    render json: ConfirmSubmission.new(submission).call
  end

  def destroy
    authorize submission

    CancelSubmission.new(submission).call

    head :no_content
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end

  def submission
    @submission ||= Submission.find(params[:id])
  end
end
