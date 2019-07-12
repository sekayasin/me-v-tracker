require "rails_helper"

RSpec.describe Feedback, type: :model do
  let(:bootcamper) { create :bootcamper_with_learner_program }
  let(:assessment) { create :assessment_with_phases }
  let(:impression) { create :impression }
  let(:details) do
    {
      learner_program_id: bootcamper.learner_programs[0].id,
      assessment_id: assessment.id,
      phase_id: assessment.phases.last.id,
      impression_id: impression.id,
      comment: "Good work"
    }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:learner_program) }
    it { is_expected.to belong_to(:phase) }
    it { is_expected.to belong_to(:assessment) }
    it { is_expected.to belong_to(:impression) }
    it { is_expected.to have_one(:reflection) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:learner_program_id) }
    it { is_expected.to validate_presence_of(:phase_id) }
    it { is_expected.to validate_presence_of(:assessment_id) }
    it { is_expected.to validate_presence_of(:impression_id) }
    it { is_expected.to validate_presence_of(:comment) }
  end

  before do
    Feedback.create details
  end

  describe ".create_or_update" do
    it "populates the Feedback table with the data and returns true" do
      feedback_instance = Feedback.create_or_update(details)

      expect(feedback_instance.assessment_id).to eql assessment.id
      expect(feedback_instance.impression_id).to eql impression.id
      expect(feedback_instance.learner_program_id).
        to eql bootcamper.learner_programs[0].id
      expect(Feedback.where(details).last.comment).to eql details[:comment]
    end
  end

  describe ".find_learner_feedback" do
    it "returns the feedback that matches the criteria specified" do
      output_params =
        {
          learner_program_id: bootcamper.learner_programs[0].id,
          assessment_id: assessment.id,
          phase_id: assessment.phases.last.id
        }
      learner_feedback = Feedback.find_learner_feedback(output_params)
      expect(learner_feedback.comment).to eql "Good work"
    end
  end
end
