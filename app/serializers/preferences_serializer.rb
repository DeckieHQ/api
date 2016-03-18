class PreferencesSerializer < ActiveModel::Serializer
  def id
    nil
  end

  attributes :notifications
end
