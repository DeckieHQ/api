class AchievementSerializer < ActiveModel::Serializer
  type 'achievements'

  attributes :name, :description
end
