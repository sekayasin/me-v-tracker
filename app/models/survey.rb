class Survey < ApplicationRecord
  self.primary_key = :survey_id
  validates :title, presence: true
  validates :link, presence: true
  validate :validate_link

  has_many :surveys_pivots,
           dependent: :destroy,
           class_name: "SurveyPivot"

  before_create do
    self.survey_id = generate_id
  end

  private

  def validate_link
    url = URI.parse(link)
    unless url.is_a?(URI::HTTP) || url.is_a?(URI::HTTPS)
      errors.add(:link, "must be a valid http:// or https://")
    end
  rescue StandardError
    errors.add(:link, "must be a valid http:// or https://")
  end
end
