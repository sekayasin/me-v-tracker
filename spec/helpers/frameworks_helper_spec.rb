require "rails_helper"

RSpec.describe FrameworksHelper, type: :helper do
  describe "#framework_collection" do
    it "returns the frameworks" do
      expect(helper.framework_collection).to eq(Framework.all)
    end
  end
end
