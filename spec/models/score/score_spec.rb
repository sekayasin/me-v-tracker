require "rails_helper"
require_relative "../../support/shared_context/score_details"

RSpec.describe Score, type: :model do
  include_context "score details"

  let(:learner_program) { create :learner_program }

  describe "Score Associations" do
    it { is_expected.to belong_to(:learner_program) }
    it { is_expected.to belong_to(:assessment) }
    it { is_expected.to belong_to(:phase) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:score) }
    it { is_expected.to validate_presence_of(:phase_id) }
    it { is_expected.to validate_presence_of(:assessment_id) }
  end

  describe ".get_bootcamper_scores" do
    context "when camper has not been scored" do
      it "returns no scores" do
        camper_scores = Score.get_bootcamper_scores(learner_program.id)
        expect(camper_scores.length).to eql(0)
      end
    end

    context "when camper has been scored" do
      it "returns all camper's scores" do
        phase1_assessments.each do |assessment|
          params = {
            score: 2.0,
            phase_id: phases[0].id,
            assessment_id: assessment[:id],
            comments: "Good work"
          }
          Score.save_score(params, learner_program.id)
        end

        camper_scores = Score.get_bootcamper_scores(learner_program.id)

        expect(camper_scores.length).to eql(4)
      end
    end

    it "returns an array of active record" do
      camper_scores = Score.get_bootcamper_scores(learner_program.id)
      expect(camper_scores).to be_a(ActiveRecord::Relation)
    end
  end
end
