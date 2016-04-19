class IndexRecordJob < ApplicationJob
  queue_as :indexation

  def perform(record_class_name, id)
    record_class_name.constantize.with_deleted.find(id).tap do |record|
      record.public_send(record.deleted? ? :remove_from_index! : :index!)
    end
  end
end
