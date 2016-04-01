class Comment::CommentsController < ApplicationController
  before_action :authenticate!, only: [:create]
  before_action :authenticate,  only: [:index]

  def index
    authorize parent

    search = Search.new(params, sort: %w(created_at))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(parent.comments)
  end

  def create
    comment = Comment.new(comment_params)
    comment.resource = parent

    authorize parent

    unless comment.save
      return return_validation_errors(comment)
    end
    render json: comment, status: :created
  end

  protected

  def parent
    @parent ||= Comment.find(params[:comment_id])
  end

  def comment_params
    permited_attributes(Comment).except(:private)
  end
end
