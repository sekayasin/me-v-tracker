require "rails_helper"

RSpec.describe SupportService do
  describe ".get_support_data" do
    it "returns the support data" do
      support = SupportService.new
      @support_data = support.get_support_data
      expect(@support_data.size).to eq 2
    end
  end
end
