class ScheduleFeedback < ApplicationRecord
  self.table_name = :schedule_feedbacks

  validates :cycle_center_id, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :program_id, presence: true
  validates :nps_question_id, presence: true

  belongs_to :nps_question,
             foreign_key: :nps_question_id

  belongs_to :cycle_center,
             foreign_key: :cycle_center_id,
             primary_key: :cycle_center_id

  scope :active, lambda {
    where("(end_date >= ? ) AND (start_date <= ? )",
          Time.now.utc, Time.now.utc)
  }
end
