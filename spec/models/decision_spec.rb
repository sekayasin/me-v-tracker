require "rails_helper"

RSpec.describe Decision, type: :model do
  let(:learner_program) { create :learner_program }
  let(:decision_one) do
    create :decision,
           decision_stage: 1,
           learner_programs_id: learner_program.id
  end

  let(:decision_two) do
    create :decision,
           decision_stage: 2,
           learner_programs_id: learner_program.id
  end

  describe "model validation" do
    it { should belong_to(:decision_reason) }
    it { should belong_to(:learner_program) }
  end

  describe "field validation" do
    it { is_expected.to validate_presence_of(:learner_program) }
    it { is_expected.to validate_presence_of(:decision_stage) }
    it { is_expected.to validate_presence_of(:decision_reason) }
  end

  describe ".get_decisions" do
    it "returns decisions for that learner program" do
      expected_decisions = [decision_one, decision_two]
      decisions = Decision.get_decisions(learner_program.id)
      expect(decisions).to eq expected_decisions
    end
  end

  describe ".save_decision" do
    it "saves decisions for that learner program" do
      expected_decisions = [decision_one, decision_two]
      decisions = Decision.save_decision(
        learner_program.id, 2, [decision_one, decision_two], "level up"
      )
      expect(decisions).to eq expected_decisions
    end
  end

  describe ".get_decision_by_stage" do
    context "When the stage is 1" do
      it "returns correct decision for that stage" do
        decision_one = decision_one
        decision = Decision.get_decision_by_stage(
          learner_program.id, 1
        )

        expect(decision).to eq decision_one
      end
    end

    context "When the stage is 2" do
      it "returns correct decision for that stage" do
        decision_two = decision_two
        decision = Decision.get_decision_by_stage(
          learner_program.id, 2
        )

        expect(decision).to eq decision_two
      end
    end

    describe ".delete_bootcamper_reasons" do
      it "deletes decisions for that learner program" do
        del_all = Decision.delete_bootcamper_reasons(
          learner_program.id
        )
        expect(del_all).to eq 0
      end
    end
  end
end
