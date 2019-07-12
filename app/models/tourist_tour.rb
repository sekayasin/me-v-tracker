class TouristTour < ApplicationRecord
  belongs_to :tourist,
             foreign_key: :tourist_email

  belongs_to :tour

  validates :tourist_email, presence: true
  validates :tour_id, presence: true
  validates :role, presence: true,
                   inclusion: { in: %w(Learner Non-LFA LFA Admin),
                                message: "is not a valid role" }
end
