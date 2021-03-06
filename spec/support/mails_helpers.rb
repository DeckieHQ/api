module MailDeliveries
  extend self
  extend Forwardable

  @deliveries = ActionMailer::Base.deliveries

  def_delegators :@deliveries, :last, :clear, :empty?, :count

  def all
    @deliveries
  end
end
