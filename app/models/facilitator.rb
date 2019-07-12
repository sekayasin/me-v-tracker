require "fancy_id"
require "uri"

class Facilitator < ApplicationRecord
  has_many :week_one_facilitators,
           class_name: "LearnerProgram", foreign_key: "week_one_facilitator_id"
  has_many :week_two_facilitators,
           class_name: "LearnerProgram", foreign_key: "week_two_facilitator_id"
  validates :id, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true,
                    uniqueness: true

  before_validation do
    remove_whitespaces if email
  end

  before_create do
    self.id = Facilitator.generate_facilitator_id
  end

  def self.generate_facilitator_id
    generate_id
  end

  private

  def remove_whitespaces
    self.email = email.downcase.strip
  end
end
