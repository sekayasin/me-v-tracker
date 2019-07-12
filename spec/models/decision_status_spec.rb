require "rails_helper"

RSpec.describe DecisionStatus, type: :model do
  context "when validating associations" do
    it "has many decision reasons" do
      is_expected.to have_many(:decision_reasons).
        through(:decision_reason_statuses)
    end
  end

  describe ".get_reasons" do
    context "when given a valid decision status" do
      it "returns the status reasons" do
        status_reasons = ["Personal/Health Reasons", "Other", "Commitment"]
        reasons = DecisionStatus.get_reasons("Dropped Out")
        expect(reasons).to match_array(status_reasons)
      end
    end

    context "when given an invalid decision status" do
      it "returns nil" do
        reasons = DecisionStatus.get_reasons("Dropped")
        expect(reasons).to be_nil
      end
    end
  end

  describe ".get_all_statuses" do
    it "returns all decision statuses" do
      statuses = DecisionStatus.get_all_statuses
      decision_statuses = DecisionStatus.all
      expect(decision_statuses.count).to eq(statuses.length)
    end
  end
end
