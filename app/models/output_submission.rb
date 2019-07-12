require "addressable/uri"
require "json"

class OutputSubmission < ApplicationRecord
  belongs_to :assessment, -> { with_deleted }
  has_many :feedback, dependent: :destroy
  belongs_to :learner_program, foreign_key: "learner_programs_id"
  belongs_to :phase
  validate :validates_submission_types
  validates_presence_of :description, message: "must be provided"
  validates_presence_of :link, if: :link_only?, message: "must be provided"
  validates_presence_of :file_link, if: :upload_only?,
                                    message: "must be provided"
  validates :assessment_id, uniqueness: {
    scope: %i(learner_programs_id phase_id submission_phase_id)
  }
  belongs_to :submission_phase, class_name: "AssessmentOutputSubmission",
                                foreign_key: "submission_phase_id"

  def self.total_links_submitted(learner_program_id)
    where(learner_programs_id: learner_program_id).count
  end

  def self.does_submission_exist?(*submission_spec)
    query = build_query(submission_spec)
    exists?(
      query
    )
  end

  def self.build_query(query_params)
    query = {
      learner_programs_id: query_params[0],
      phase_id: query_params[1],
      assessment_id: query_params[2]
    }
    if !!query_params[3]
      query[:submission_phase_id] = query_params[3]
    end
    query
  end

  private_class_method :build_query

  private

  def link_must_be_valid
    url = URI.parse(link)
    unless url_is_valid?(url)
      errors.add(:link, "must be a valid http:// or https:// url")
    end
  rescue StandardError
    errors.add(:link, "must be a valid http:// or https:// url")
  end

  def url_is_valid?(url)
    url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
  end

  def link_only?
    return unless assessment

    !!assessment.submission_types && assessment.submission_types == "link"
  end

  def upload_only?
    return unless assessment

    type = "file"
    !!assessment.submission_types && assessment.submission_types == type
  end

  def validates_submission_types
    !link.blank? && link_must_be_valid
    if submission_valid?
      submission = yield_submitted_output
      error = "should contain a file or a link"
      errors[:Submission] << error unless submission
    end
  end

  def yield_submitted_output
    output = check_if_blank(link) || check_if_blank(file_link)
    output
  end

  def check_if_blank(arg)
    return false unless arg && !arg.blank?

    arg
  end

  def submission_valid?
    permitted_types = ["file", "link", "file, link"]
    assessment&.submission_types &&
      permitted_types.include?(assessment.submission_types)
  end
end
