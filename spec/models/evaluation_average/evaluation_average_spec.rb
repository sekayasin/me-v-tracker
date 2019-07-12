require "rails_helper"

RSpec.describe EvaluationAverage, type: :model do
  let(:learner_program) { create :learner_program }

  describe "Associations" do
    it { is_expected.to have_many(:holistic_evaluations) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:holistic_average) }
    it { is_expected.to validate_presence_of(:dev_framework_average) }
  end

  describe ".calculate_average" do
    test_scores = [1, 2]

    it "returns correct average of integer array" do
      average = EvaluationAverage.calculate_average(test_scores)
      expect(average).to eq(1.5)
    end
  end
end
