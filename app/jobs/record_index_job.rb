class RecordIndexJob < ApplicationJob
  queue_as :default

  def perform(id, class_name, remove)
    record = class_name.constantize.with_deleted.find(id)

    record.tap(& remove ? :remove_from_index! : :index!)
  end
end
