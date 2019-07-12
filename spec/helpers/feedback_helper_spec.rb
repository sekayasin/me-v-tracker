require "rails_helper"

describe FeedbackControllerHelper, type: :helper do
  let(:impression) { create :impression }
  let(:assessment) { create :assessment }
  let(:learner_program) { create :learner_program }
  let(:learner_program1) { create :learner_program }
  let(:email) { learner_program1.bootcamper.email }
  let(:phase) { create :phase, name: "Project" }
  let!(:programs_phase) do
    create(
      :programs_phase,
      program_id: learner_program1.program.id,
      phase_id: phase.id
    )
  end

  let!(:feedback) do
    Feedback.create(
      learner_program_id: learner_program1.id,
      phase_id: phase.id,
      assessment_id: assessment.id,
      impression_id: impression.id,
      comment: "Good work"
    )
  end

  describe ".populate_feedback" do
    context "When the learner has feedback" do
      it "returns all the feedback related to the learner in an array" do
        learner_details = LearnerProgram.get_all_learner_feedback(email)
        learner_feedback = populate_feedback(learner_details.feedback)
        expect(learner_feedback.length).to eql 1
      end
    end

    context "When the learner has no existing feedback" do
      it "returns an empty array" do
        email = learner_program.bootcamper.email
        learner_details = LearnerProgram.get_all_learner_feedback(email)
        learner_feedback = populate_feedback(learner_details.feedback)
        expect(learner_feedback.length).to eql 0
      end
    end
  end
end
