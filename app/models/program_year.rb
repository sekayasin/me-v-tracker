require "fancy_id"

class ProgramYear < ApplicationRecord
  belongs_to :year
  belongs_to :target

  before_create do
    self.program_year_id = generate_id
  end
end
