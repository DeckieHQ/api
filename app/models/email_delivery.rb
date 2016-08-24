class EmailDelivery < ApplicationRecord
  self.inheritance_column = nil
  
  belongs_to :receiver, class_name: 'User', foreign_key: 'user_id'

  belongs_to :resource, polymorphic: true
end
