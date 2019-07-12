require "fancy_id"
require "uri"

class NpsRating < ApplicationRecord
  self.primary_key = :nps_ratings_id

  validates :rating, presence: true

  has_many :nps_responses,
           dependent: :destroy,
           class_name: "NpsResponse"

  before_create do
    self.nps_ratings_id = generate_id
  end
end
