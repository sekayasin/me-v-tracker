require "rails_helper"
require_relative "../../support/shared_context/score_details"

RSpec.describe Score, type: :model do
  include_context "score details"

  let(:learner_program) { create :learner_program }

  describe ".overall_average" do
    context "when camper has not been scored" do
      it "returns 0.0 as overall average" do
        expect(Score.overall_average(learner_program.id)).to eql(0.0)
      end
    end

    context "when camper has been scored" do
      it "returns camper's overall average" do
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
              score: 2.0,
              phase_id: phases[0].id,
              assessment_id: assessment[:id],
              comments: "Good work"
            },
            learner_program.id
          )
        end

        expect(Score.overall_average(learner_program.id)).to eql(2.0)
      end
    end

    it "returns a number" do
      expect(Score.overall_average(learner_program.id)).to be_a(Numeric)
    end
  end
end
