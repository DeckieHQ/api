class RecordIndexJob < ApplicationJob
  queue_as :indexation

  def perform(model_name, id)
    record = model_name.constantize.with_deleted.find(id)

    record.tap(& record.deleted? ? :remove_from_index! : :index!)
  end
end
