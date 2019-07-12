require "rails_helper"

describe DecisionsControllerHelper, type: :helper do
  let(:first_learner_program) { create :learner_program, :accepted }
  let(:second_learner_program) { create :learner_program }
  let(:valid_decision) do
    create :decision, learner_programs_id: first_learner_program.id
  end
  let(:invalid_decision) do
    create :decision, learner_programs_id: second_learner_program.id
  end

  describe "#prepare_decision_history" do
    it "returns array of formatted decisions" do
      decisions = prepare_decision_history([valid_decision])
      expect(decisions.first[:details][:Comment]).to eq valid_decision.comment
    end
  end

  describe "#get_decision_status" do
    it "returns decision status for that stage" do
      decision_status = get_decision_status(valid_decision)
      expect(decision_status).to eq valid_decision.learner_program.decision_one
    end
  end

  describe "#list_decision_reasons" do
    it "returns a list of reasons for that decision" do
      reasons_list = list_decision_reasons([valid_decision])
      expect(reasons_list).to eq [valid_decision.decision_reason.reason]
    end
  end

  describe "#decision_valid?" do
    context "when decision status is 'In Progress' or 'Not Applicable'" do
      it "returns false" do
        decision = decision_valid?(invalid_decision)
        expect(decision).to be false
      end
    end

    context "when decision status is not 'In Progress' or 'Not Applicable'" do
      it "returns true" do
        decision = decision_valid?(valid_decision)
        expect(decision).to be true
      end
    end
  end

  describe "#get_lfa_email" do
    it "returns lfa email for that decision stage" do
      lfa_email = get_lfa_email(valid_decision)
      expect(lfa_email).to eq valid_decision.
        learner_program.
        week_one_facilitator.
        email
    end
  end

  describe "#get_lfa_name" do
    it "returns lfa name from email" do
      name = get_lfa_name("lionel.messi@example.com")
      expect(name).to eq("Lionel Messi")
    end
  end

  describe "#capitalize_lfa_name" do
    it "returns capitalized name" do
      name = capitalize_lfa_name(%w(lionel messi))
      expect(name).to eq("Lionel Messi")
    end
  end
end
