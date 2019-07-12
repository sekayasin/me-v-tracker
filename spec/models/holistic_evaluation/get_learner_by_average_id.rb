require "rails_helper"

RSpec.describe HolisticEvaluation, type: :model do
  describe ".get_average_by_learner_id" do
    let(:learner_program) { create :learner_program }
    let(:evaluation_average) { create :evaluation_average }
    let!(:holistic_evaluation) do
      create(:holistic_evaluation,
             learner_program: learner_program,
             evaluation_average: evaluation_average)
    end

    it "finds an evaluation average record by id" do
      average_record = HolisticEvaluation.
                       get_average_by_learner_id(learner_program.id)

      expect(average_record).to be_instance_of(EvaluationAverage)
      expect(average_record.id).to eq(evaluation_average.id)
    end
  end
end
