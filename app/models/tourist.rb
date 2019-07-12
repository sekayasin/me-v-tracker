class Tourist < ApplicationRecord
  self.primary_key = :tourist_email

  has_many :tourist_tours,
           foreign_key: :tourist_email

  validates :tourist_email, presence: true
end
