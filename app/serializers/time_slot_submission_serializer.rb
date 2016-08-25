class TimeSlotSubmissionSerializer < ActiveModel::Serializer
  attributes :created_at

  belongs_to :time_slot
  belongs_to :profile
end
