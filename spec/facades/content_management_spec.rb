require "rails_helper"

RSpec.describe ContentManagementFacade, type: :facade do
  let(:facade_object) { ContentManagementFacade.new }
  describe "get content" do
    it "returns all contents" do
      expect(facade_object.get_content.count).to eq 7
    end
  end
end
