class Subscription < ApplicationRecord
  belongs_to :event
  belongs_to :profile
end
