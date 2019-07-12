require "rails_helper"

RSpec.describe HolisticEvaluation, type: :model do
  include_context "holistic evaluation data"

  describe ".save_holistic_evaluations" do
    it "creates holistic evaluation records" do
      evaluation_count = HolisticEvaluation.
                         where(learner_program_id: learner_program.id).count

      HolisticEvaluation.save_holistic_evaluations(
        data[:holistic_evaluation],
        learner_program.id,
        evaluation_average.id
      )

      new_count = HolisticEvaluation.
                  where(learner_program_id: learner_program.id).count

      expect(new_count).to eq(evaluation_count + 2)
    end
  end
end
