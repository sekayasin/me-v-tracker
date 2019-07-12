class Rating < ApplicationRecord
  belongs_to :panelist
  belongs_to :learners_pitch

  validates :learners_pitch_id, presence: true
  validates :panelist_id, presence: true
  validates :ui_ux, presence: true,
                    inclusion: { in: [1, 2, 3, 4, 5],
                                 message: "invalid rating" }
  validates :api_functionality, presence: true,
                                inclusion: { in: [1, 2, 3, 4, 5],
                                             message: "invalid rating" }
  validates :error_handling, presence: true,
                             inclusion: { in: [1, 2, 3, 4, 5],
                                          message: "invalid rating" }
  validates :project_understanding, presence: true,
                                    inclusion: { in: [1, 2, 3, 4, 5],
                                                 message: "invalid rating" }
  validates :presentational_skill, presence: true,
                                   inclusion: { in: [1, 2, 3, 4, 5],
                                                message: "invalid rating" }
  validates :decision, presence: true,
                       inclusion: { in: %w(Yes No Maybe),
                                    message: "invalid decision" }
  validates :comment, presence: true
end
