class TimeSlotSubmission < ApplicationRecord
  include Filterable

  belongs_to :time_slot, counter_cache: :members_count

  belongs_to :profile
end
