class CommentsController < ApplicationController
  before_action :authenticate!, only: [:update, :destroy]

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

  def comment
    @comment ||= Comment.find(params[:id])
  end

  def comment_params
    permited_attributes(comment)
  end
end
