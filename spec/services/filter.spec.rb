require "rails_helper"

RSpec.describe FilterService do
  describe ".build_filter_terms" do
    context "when multiple filter values are selected" do
      it "returns an array of the items" do
        build_params = FilterService.build_filter_terms("BootcampV1,Andela Alc")
        expect(build_params).to eq ["BootcampV1", "Andela Alc"]
      end
    end

    context "when no value is supplied" do
      it "returns All as a filtering parameter" do
        build_params = FilterService.build_filter_terms(nil)
        expect(build_params).to eq "All"
      end
    end
  end
end
