require "rails_helper"
require_relative "../../support/shared_context/score_details"

RSpec.describe Score, type: :model do
  include_context "score details"

  let(:learner_program) { create :learner_program }

  describe ".framework_averages" do
    context "when camper has not been scored" do
      it "returns ['0.0', '0.0', '0.0'] as framework averages" do
        framework_averages = Score.framework_averages(learner_program.id)
        expect(framework_averages).to eq([0.0, 0.0, 0.0])
      end
    end

    context "when camper has been scored" do
      it "returns camper's framework averages" do
        phase1_assessments.each do |assessment|
          Score.save_score(
            {
              score: 2.0,
              phase_id: phases[0].id,
              assessment_id: assessment[:id],
              comments: "Good work"
            },
            learner_program.id
          )
        end

        phase2_assessments.each do |assessment|
          Score.save_score(
            {
              score: 1.0,
              phase_id: phases[1].id,
              assessment_id: assessment[:id],
              comments: "Good work"
            },
            learner_program.id
          )
        end

        other_assessments.each do |assessment|
          Score.save_score(
            {
              score: 0.0,
              phase_id: phases[2].id,
              assessment_id: assessment[:id],
              comments: "Good work"
            },
            learner_program.id
          )
        end

        framework_averages = Score.framework_averages(learner_program.id)
        expect(framework_averages).to eq([2.0, 0.8, 0.0])
      end
    end
  end
end
