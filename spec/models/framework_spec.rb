require "rails_helper"

RSpec.describe Framework, type: :model do
  describe "Validations" do
    it { is_expected.to have_many(:criteria).through(:framework_criteria) }
    it { is_expected.to have_many(:assessments).through(:framework_criteria) }
    it { is_expected.to have_many(:scores).through(:assessments) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe "get_assessments_count" do
    let(:framework_criterium) { FrameworkCriterium.first }
    let(:framework) { Framework.first }

    it "returns framework assessments count" do
      expect(framework.get_assessments_count(framework_criterium.id)).to be >= 1
    end
  end

  describe ".get_program_frameworks" do
    let(:program) { Program.first }

    it "returns frameworks for current program" do
      expect(Framework.get_program_frameworks(program.id).length).to be >= 1
    end
  end
end
