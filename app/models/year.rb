require "fancy_id"

class Year < ApplicationRecord
  has_many :program_years
  has_many :targets, through: :program_years

  before_create do
    self.year_id = generate_id
  end
end
