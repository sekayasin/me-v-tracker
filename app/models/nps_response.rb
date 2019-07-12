require "fancy_id"
require "uri"

class NpsResponse < ApplicationRecord
  self.primary_key = :nps_response_id
  self.table_name = :nps_responses

  validates :nps_ratings_id, presence: true
  validates :nps_question_id, presence: true
  validates :cycle_center_id, presence: true
  validates :camper_id, presence: true

  belongs_to :nps_question,
             foreign_key: :nps_question_id

  belongs_to :nps_rating,
             foreign_key: :nps_ratings_id

  belongs_to :cycle_center,
             foreign_key: :cycle_center_id,
             primary_key: :cycle_center_id

  before_create do
    self.nps_response_id = generate_id
  end
end
