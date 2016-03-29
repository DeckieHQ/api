class CommentsController < ApplicationController
  before_action :authenticate!, only: [:create, :update, :destroy]
  before_action :authenticate,  only: [:index]

  def index
    scope = CommentsScope.new(current_user, event)

    search = Search.new(params, sort: %w(created_at), filters: scope.filters)

    return render_search_errors(search) unless search.valid?

    render json: search.apply(scope.default)
  end

  def create
    comment = Comment.new(comment_params)
    comment.resource = event

    authorize comment

    unless comment.save
      return return_validation_errors(comment)
    end
    render json: comment, status: :created
  end

  def update
    authorize comment

    unless comment.update(comment_params)
      return render_validation_errors(comment)
    end
    render json: comment
  end

  def destroy
    authorize comment

    CancelComment.new(comment).call

    head :no_content
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end

  def comment
    @comment ||= Comment.find(params[:id])
  end

  def comment_params
    attributes(:comments).permit(policy(Comment).permited_attributes)
  end
end
