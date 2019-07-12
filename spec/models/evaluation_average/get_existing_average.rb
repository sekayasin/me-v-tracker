require "rails_helper"

RSpec.describe EvaluationAverage, type: :model do
  let(:learner_program) { create :learner_program }

  describe ".get_existing_average" do
    context "when evaluations do not exist" do
      it "returns 0.0" do
        average = EvaluationAverage.get_existing_average(learner_program.id)
        expect(average).to eq(0.0)
      end
    end

    context "when evaluations exist" do
      let(:evaluation_average) { create :evaluation_average }
      let(:dev_framework_criterium) do
        create(:criterium, belongs_to_dev_framework: true)
      end

      let!(:first_holistic_evaluation) do
        create(:holistic_evaluation, score: 2, learner_program: learner_program)
      end

      let!(:second_holistic_evaluation) do
        create(:holistic_evaluation,
               score: 1,
               criterium: dev_framework_criterium,
               learner_program: learner_program)
      end

      it "returns correct holistic average" do
        average = EvaluationAverage.get_existing_average(learner_program.id)
        expect(average).to eq(1.5)
      end

      it "returns correct dev framework average" do
        average = EvaluationAverage.
                  get_existing_average(learner_program.id, true)
        expect(average).to eq(1)
      end
    end
  end
end
