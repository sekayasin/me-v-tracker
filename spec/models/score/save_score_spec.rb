require "rails_helper"
require_relative "../../support/shared_context/score_details"

RSpec.describe Score, type: :model do
  include_context "score details"

  let(:learner_program) { create :learner_program }

  describe ".save_score" do
    before(:all) do
      Score.delete_all
    end

    context "when camper has not been scored" do
      it "scores should be empty" do
        expect(Score.all).to be_empty
      end
    end

    context "when assessment score does not exist" do
      it "creates the score for the camper" do
        Score.save_score(score_params, learner_program.id)
        expect(Score.all.count).to eql(1)
      end

      it "saves camper's score" do
        Score.save_score(score_params, learner_program.id)
        camper_score = Score.where(
          learner_programs_id: learner_program.id,
          assessment_id: phase1_assessments[0][:id]
        ).first
        expect(camper_score.score).to eql(1.0)
      end
    end

    context "when assessment score exists for camper" do
      it "does not duplicate the score" do
        3.times do
          Score.save_score(score_params, learner_program.id)
        end
        score = Score.where(
          learner_programs_id: learner_program.id,
          assessment_id: score_params[:assessment_id],
          phase_id: score_params[:phase_id]
        )
        expect(score.size).to eql(1)
      end

      it "updates camper's score" do
        Score.save_score(score_params, learner_program.id)
        score_params[:score] = 2.0
        score_params[:original_updated_at] = 1.year.from_now
        Score.save_score(score_params, learner_program.id)
        expect(Score.last.score).to eql(2.0)
      end
    end
  end
end
