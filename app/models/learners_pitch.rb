class LearnersPitch < ApplicationRecord
  belongs_to :pitch
  belongs_to :bootcamper, foreign_key: :camper_id
  has_many :ratings
  validates :camper_id, presence: true
  validates :pitch_id, presence: true
end
