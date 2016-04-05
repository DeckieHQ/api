class Event::CommentsController < ApplicationController
  before_action :authenticate!, only: [:create]
  before_action :authenticate,  only: [:index]

  def index
    scope = CommentsScope.new(current_user, event)

    search = Search.new(params, sort: %w(created_at), include: %w(author), filters: scope.filters)

    return render_search_errors(search) unless search.valid?

    render json: search.apply(scope.default), include: search.included
  end

  def create
    comment = Comment.new(comment_params)
    comment.resource = event
    comment.author = current_user.profile

    authorize comment

    result = AddComment.new(comment).call

    if result.errors.present?
      return render_validation_errors(result)
    end
    render json: result, status: :created
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end

  def comment_params
    permited_attributes(Comment)
  end
end
