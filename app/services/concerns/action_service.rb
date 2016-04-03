class ActionService
  def initialize(actor, resource)
    @actor    = actor
    @resource = resource
  end

  private

  attr_reader :actor, :resource

  def create_action(type)
    Action.create(actor: actor, resource: resource, type: type, notify: :later)
  end
end
