class CancelComment
  def initialize(comment)
    @comment = comment
  end

  def call
    comment.destroy
  end

  private

  attr_reader :comment
end
