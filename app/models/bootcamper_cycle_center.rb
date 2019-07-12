require "fancy_id"

class BootcamperCycleCenter < ApplicationRecord
  self.primary_key = :bcc_id
  self.table_name = :bootcampers_cycles_centers

  belongs_to :cycle_center,
             primary_key: :cycle_center_id,
             foreign_key: :cycle_center_id

  belongs_to :bootcamper,
             primary_key: :camper_id,
             foreign_key: :camper_id

  before_create do
    self.bcc_id = generate_id
  end
end
