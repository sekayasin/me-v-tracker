class Pitch < ApplicationRecord
  has_many :panelists, dependent: :destroy
  has_many :learners_pitches, dependent: :destroy

  belongs_to :cycles_center, foreign_key: :cycle_center_id

  validates :cycle_center_id, presence: true
  validates :demo_date, presence: true
end
