class Panelist < ApplicationRecord
  has_many :ratings
  belongs_to :pitch

  validates :pitch_id, presence: true
  # rubocop:disable Style/MutableConstant
  VALID_EMAIL_REGEX = /\A[a-z]{2,}\.[a-z]{2,}@andela.com\z/
  # rubocop:enable Style/MutableConstant
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :accepted, presence: true,
                       inclusion: { in: %w(True False),
                                    message: "invalid acceptance status" }
end
