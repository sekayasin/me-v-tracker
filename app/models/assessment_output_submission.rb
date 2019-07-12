class AssessmentOutputSubmission < ApplicationRecord
  has_many :output_submissions, foreign_key: "submission_phase_id"
  belongs_to :assessment
  belongs_to :phase
  validates :position, :day, presence: true, numericality: true
  validates :assessment_id, presence: true
  validates :phase_id, :file_type, presence: true
end
