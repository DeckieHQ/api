class Profile < ApplicationRecord
  acts_as_paranoid

  mount_base64_uploader :avatar, AvatarUploader

  belongs_to :user

  has_many :submissions

  has_many :hosted_events, class_name: :Event

  has_many :opened_hosted_events, -> { opened }, class_name: :Event

  validates :nickname,          length: { maximum: 64   }
  validates :short_description, length: { maximum: 140  }
  validates :description,       length: { maximum: 8192 }

  validates_integrity_of :avatar

  validates_processing_of :avatar

  after_update :reindex_opened_hosted_events, if: :changed?

  private

  def reindex_opened_hosted_events
    ReindexRecordsJob.perform_later('Event', opened_hosted_events.pluck('id'))
  end
end
