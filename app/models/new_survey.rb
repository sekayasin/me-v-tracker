class NewSurvey < ApplicationRecord
  before_validation :default_values
  validates :end_date, presence: true, if: :status_is_published?
  validates :start_date, presence: true, if: :status_is_published?
  validates :title, presence: true
  validates :survey_creator, presence: true
  validates_inclusion_of(:status,
                         in: %w(draft published completed archived),
                         on: %i(create update),
                         message: "%s is not a valid status")
  has_many :survey_sections, dependent: :destroy
  has_many :survey_responses, dependent: :destroy
  has_and_belongs_to_many :cycle_centers,
                          join_table: :cycle_centers_new_surveys
  has_many :collaborators, through: :new_survey_collaborators,
                           dependent: :destroy
  has_many :new_survey_collaborators, dependent: :destroy
  before_destroy { cycle_centers.clear }

  scope :active, lambda {
    where("(end_date >= ? ) AND (start_date <= ? )",
          Time.now.utc, Time.now.utc)
  }

  scope :published, -> { where(status: "published") }
  scope :due_response, lambda {
    where("end_date <= ? AND end_date > ?", 1.day.from_now, Date.today)
  }

  private

  def default_values
    self.status ||= "draft"
  end

  def status_is_published?
    self.status == "published"
  end
end
