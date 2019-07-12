class Tour < ApplicationRecord
  has_many :tourist_tours

  validates :name, presence: true
end
