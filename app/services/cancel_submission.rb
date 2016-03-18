class CancelResourceWithAction
  def self.for(resources)
    resources.map { |resource| new(resource) }
  end

  def initialize(resource)
    @resource = resource
  end

  def call
    resource.destroy
  end

  private

  attr_reader :resource
end
