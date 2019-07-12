require "rails_helper"

RSpec.describe DecisionService do
  describe ".get_decision_data" do
    it "returns the correct number of decision items" do
      decision = DecisionService.new
      @decision_data = decision.get_decision_data
      expect(@decision_data.size).to eq 8
    end
  end
end
