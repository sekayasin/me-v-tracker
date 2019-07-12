require "rails_helper"

RSpec.describe AssessmentOutputSubmission, type: :model do
  context "Validations" do
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_presence_of(:day) }
    it { is_expected.to validate_presence_of(:phase_id) }
    it { is_expected.to validate_presence_of(:assessment_id) }
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_numericality_of(:position) }
    it { is_expected.to validate_presence_of(:file_type) }
  end

  context "Associations" do
    it {
      is_expected.to have_many(:output_submissions).
        with_foreign_key("submission_phase_id")
    }
    it { is_expected.to belong_to(:phase) }
    it { is_expected.to belong_to(:assessment) }
  end
end
