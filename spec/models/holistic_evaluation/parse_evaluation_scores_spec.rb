require "rails_helper"

RSpec.describe HolisticEvaluation, type: :model do
  include_context "holistic evaluation data"

  describe ".parse_evaluation_scores" do
    it "returns array correct holistic scores" do
      scores = HolisticEvaluation.
               parse_evaluation_scores(data[:holistic_evaluation])
      expect(scores).to match_array([2, 1])
    end

    it "returns array correct dev framework scores" do
      scores = HolisticEvaluation.
               parse_evaluation_scores(data[:holistic_evaluation],
                                       true)
      expect(scores).to match_array([1])
    end
  end
end
