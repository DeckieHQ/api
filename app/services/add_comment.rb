class AddComment < ActionService
  def initialize(comment)
    super(comment.author, comment.resource)

    @comment = comment
  end

  def call
    create_action(:comment) if comment.save

    comment
  end

  private

  attr_reader :comment
end
