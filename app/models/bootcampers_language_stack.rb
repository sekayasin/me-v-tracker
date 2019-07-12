class BootcampersLanguageStack < ApplicationRecord
  belongs_to :bootcamper, foreign_key: :camper_id
  belongs_to :language_stack

  validates :camper_id, presence: true
  validates :language_stack_id, presence: true
end
