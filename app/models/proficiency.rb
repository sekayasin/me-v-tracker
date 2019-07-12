class Proficiency < ApplicationRecord
  has_many :bootcampers

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
end
