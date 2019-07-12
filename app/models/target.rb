require "fancy_id"

class Target < ApplicationRecord
  has_many :program_years
  has_many :years, through: :program_years

  before_create do
    self.target_id = generate_id
  end
end
