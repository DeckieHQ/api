class CommentsController < ApplicationController
  before_action :authenticate!, only: [:create, :destroy]

  def index
    search = Search.new(params, sort: %w(created_at))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(event.comments)
  end

  def create
    comment = Comment.new(comment_params)

    unless event.comments << comment
      return return_validation_errors(comment)
    end
    render json: comment, status: :created
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
