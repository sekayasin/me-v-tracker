class SurveyQuestion < ApplicationRecord
  before_validation :default_values

  validates :question, presence: true
  validates :position, presence: true
  validates_inclusion_of :description_type,
                         in: %w(text video image),
                         on: %i(create update),
                         message: "is invalid"
  validates :survey_section_id, presence: true
  validates :questionable_id, presence: true
  validates :questionable_type,
            presence: true,
            inclusion: {
              in: %w(
                SurveyOptionQuestion
                SurveyDateQuestion
                SurveyTimeQuestion
                SurveyParagraphQuestion
                SurveyScaleQuestion
              ),
              on: %i(create update),
              message: "is invalid"
            }

  belongs_to :survey_section, dependent: :destroy
  belongs_to :questionable, polymorphic: true, dependent: :destroy

  private

  def default_values
    self.description ||= ""
    self.description_type ||= "text"
    self.is_required ||= false
  end
end
