class FeedbackPolicy < ApplicationPolicy
  def permited_attributes
    [:title, :description, :email]
  end
end
