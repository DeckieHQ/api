class FeedbackPolicy < ApplicationPolicy
  def permited_attributes
    [:title, :description]
  end
end
