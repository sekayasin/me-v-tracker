require "rails_helper"

RSpec.describe HolisticEvaluation, type: :model do
  include_context "holistic evaluation details"

  describe "Associations" do
    it { is_expected.to belong_to(:learner_program) }
    it { is_expected.to belong_to(:criterium) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:learner_program_id) }
    it { is_expected.to validate_presence_of(:criterium_id) }
    it { is_expected.to validate_presence_of(:score) }
  end

  describe ".get_evaluations" do
    let!(:first_holistic_evaluation) do
      create(:holistic_evaluation, learner_program: learner_program)
    end

    let!(:second_holistic_evaluation) do
      create(:holistic_evaluation, learner_program: learner_program)
    end

    it "gets holistic evaluations from the database" do
      expect(HolisticEvaluation.get_evaluations(
        learner_program.id
      )[0].score).to eql first_holistic_evaluation.score

      expect(HolisticEvaluation.get_evaluations(
        learner_program.id
      )[1].score).to eql second_holistic_evaluation.score
    end
  end
end
