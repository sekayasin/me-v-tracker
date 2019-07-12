require "rails_helper"

RSpec.describe HolisticEvaluation, type: :model do
  include_context "holistic evaluation data"

  describe ".get_scores" do
    let!(:first_holistic_evaluation) do
      create(:holistic_evaluation, score: 2, learner_program: learner_program)
    end

    let!(:second_holistic_evaluation) do
      create(
        :holistic_evaluation,
        score: 1,
        criterium: dev_framework_criterium,
        learner_program: learner_program
      )
    end

    it "returns correct dev framework scores" do
      scores = HolisticEvaluation.get_scores(learner_program.id, true)

      expect(scores).to match_array([1])
    end

    it "returns correct holistic scores" do
      scores = HolisticEvaluation.get_scores(learner_program.id)
      expect(scores).to match_array([2, 1])
    end
  end
end
