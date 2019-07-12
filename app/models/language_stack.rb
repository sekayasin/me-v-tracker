class LanguageStack < ApplicationRecord
  has_many :dlc_stacks
  has_many :programs, through: :dlc_stacks
  has_many :bootcampers_language_stacks
  has_many :bootcampers, through: :bootcampers_language_stacks

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
