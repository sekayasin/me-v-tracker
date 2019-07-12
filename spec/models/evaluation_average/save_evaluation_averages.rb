require "rails_helper"

RSpec.describe EvaluationAverage, type: :model do
  let(:learner_program) { create :learner_program }

  describe ".save_evaluation_averages" do
    def save_evaluation_average
      EvaluationAverage.save_evaluation_averages(holistic_scores,
                                                 dev_framework_scores,
                                                 learner_program.id)
    end

    context "when passed new scores and no evaluation averages exist" do
      it "creates a new averages record" do
        evaluation_average = save_evaluation_average

        expect(evaluation_average).to be_instance_of(EvaluationAverage)
        expect(evaluation_average.holistic_average).to eq(1.5)
        expect(evaluation_average.dev_framework_average).to eq(1)
      end
    end

    context "when passed new scores and evaluation averages exist" do
      let(:evaluation_average) do
        create(:evaluation_average,
               holistic_average: -2,
               dev_framework_average: 0)
      end

      let!(:holistic_evaluation) do
        create(:holistic_evaluation,
               score: -2,
               learner_program: learner_program,
               evaluation_average: evaluation_average)
      end

      it "updates the existing averages record" do
        evaluation_average = save_evaluation_average

        expect(evaluation_average).to be_instance_of(EvaluationAverage)
        expect(evaluation_average.holistic_average).to eq(0.3)
        expect(evaluation_average.dev_framework_average).to eq(1)
      end
    end
  end
end
