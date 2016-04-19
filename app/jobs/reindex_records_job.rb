class ReindexRecordsJob < ApplicationJob
  queue_as do
    ids = self.arguments.last

    ids.empty? ? :scheduler : :indexation
  end

  def perform(record_class_name, ids = [])
    record_class = record_class_name.constantize

    ids.empty? ? record_class.reindex! : record_class.where(id: ids).reindex!
  end
end
