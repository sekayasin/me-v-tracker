class NotificationsMessage < ApplicationRecord
  has_many :notification
  belongs_to :notification_group
end
