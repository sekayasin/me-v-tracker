class Reflection < ApplicationRecord
  validates :comment, presence: true

  belongs_to :feedback
end
