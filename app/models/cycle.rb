require "fancy_id"

class Cycle < ApplicationRecord
  self.primary_key = :cycle_id

  validates :cycle, presence: true, uniqueness: true

  has_many :cycles_centers,
           dependent: :destroy,
           class_name: "CycleCenter"

  before_create do
    self.cycle_id = generate_id
  end
end
