require "rails_helper"

RSpec.describe Assessment, type: :model do
  context "Associations" do
    it { is_expected.to have_many(:scores) }
    it { is_expected.to have_many(:output_submissions) }
    it { is_expected.to have_many(:feedback) }
    it { is_expected.to belong_to(:framework_criterium) }
    it { is_expected.to have_many(:submission_phases) }
    it { is_expected.to have_and_belong_to_many(:phases) }
  end

  context "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:context) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:framework_criterium_id) }
  end

  let(:assessment_with_phases) { create :assessment_with_phases }
  let(:criterium_id) { assessment_with_phases.criterium.id }
  let(:invalid_id) { 40_000 }
  let(:program) { Program.first }
  let(:assessment) { Assessment.get_assessments_by_program(program.id) }

  describe ".get_assessments_by_program" do
    it "returns the assessments for a program" do
      expect(Assessment.get_assessments_by_program(program.id)[0].to_json).
        not_to be_empty
    end
  end

  describe ".get_required_submissions_count" do
    let!(:phases) { create_list :phase, 7 }
    it "returns the total count of phase assessments that require submission" do
      # create 3 assessments that require submission for each phase
      phases.each do |phase|
        create_list :assessment, 3, :requires_submissions, phases: [phase]
      end
      expect(Assessment.get_required_submissions_count(phases)).to eq 21
    end
  end

  describe ".get_assessments_by_phase" do
    it "returns the assessments for a phase" do
      expect(Assessment.get_assessments_by_phase(program.id).to_json).
        to include "Learning Clinic"
    end
  end

  describe "#get_details_by_phase" do
    context "when given phase has assessment" do
      let(:phase_id) { assessment_with_phases.phases.last.id }
      let(:assessment_info) do
        Assessment.new.get_details_by_phase(phase_id)
      end

      it "returns the assessment(s) information related to the phase" do
        expect(assessment_info.last.criteria_id).to eql(criterium_id)
      end
    end

    context "when given phase has no assessment" do
      let(:assessment_info) do
        Assessment.new.get_details_by_phase(invalid_id)
      end

      it "returns an empty array of assessment" do
        expect(assessment_info).to be_empty
      end
    end
  end

  describe "requires submission validation" do
    context "when both requires submission and submission_types present" do
      let(:valid_assessment) do
        build(:assessment, requires_submission: true, submission_types: "link")
      end
      it "is valid and saves successfully" do
        expect(valid_assessment.valid?).to eq(true)
        expect(valid_assessment.save).to eq(true)
      end
    end
  end
end
