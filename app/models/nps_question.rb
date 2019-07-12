require "fancy_id"
require "uri"

class NpsQuestion < ApplicationRecord
  self.primary_key = :nps_question_id

  validates :question, presence: true
  validates :title, presence: true
  validates :description, presence: true

  has_many :nps_responses,
           dependent: :destroy,
           class_name: "NpsResponse"

  has_many :schedule_feedbacks,
           dependent: :destroy,
           class_name: "ScheduleFeedback"

  before_create do
    self.nps_question_id = generate_id
  end
end
