class Impression < ApplicationRecord
  has_many :feedback

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
