require "rails_helper"

RSpec.describe ProgramsControllerHelper, type: :helper do
  let(:params) do
    {
      program: {
        program_id: 2,
        name: "Bootcamp Version 5"
      }
    }
  end

  describe ".has_phases?" do
    context "when params does not include phases but has a program id" do
      it "returns true" do
        expect(has_phases?).to eq true
      end
    end

    context "when params include phases" do
      it "returns true" do
        params[:program][:phases] = ["phase 30"]
        expect(has_phases?).to eq true
      end
    end
  end
end
