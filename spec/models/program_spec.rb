require "rails_helper"

RSpec.describe Program, type: :model do
  include_context "program phase context"

  describe "Program Associations" do
    it { is_expected.to have_many(:phases).through(:programs_phase) }
    it { is_expected.to have_many(:bootcampers) }
    it { is_expected.to have_many(:language_stacks).through(:dlc_stacks) }
    it { is_expected.to belong_to(:cadence) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe ".get_finalized_programs" do
    it "returns all finalized programs" do
      expect(Program.get_finalized_programs.length).to eql(1)
    end
  end

  describe ".maximum_holistic_evaluations" do
    let(:cadence) { Cadence.first }
    let(:program) { create :program, cadence_id: cadence.id }

    it "returns the number of maximum holistic evaluations" do
      expect(Program.maximum_holistic_evaluations(program.id)).to eq(2)
    end
  end

  describe "#assessment_options" do
    let(:cadence) { Cadence.first }
    let(:program) { create :program, cadence_id: cadence.id }
    let(:assessment_options) { program.assessment_options }

    it "returns an array with two items" do
      expect(assessment_options.length).to eql(2)
    end

    it "returns cadence of program" do
      expect(assessment_options.to_json).to include "cadence"
      expect(assessment_options[:cadence]).to eql(cadence.name)
    end

    it "returns assesments for a program" do
      expect(assessment_options.to_json).to include "assessments"
      expect(assessment_options[:assesments]).to eql(nil)
    end
  end

  describe ".program_phases" do
    it "returns program phase names" do
      program_phase = programs_phase.phase.name

      expect(Program.program_phases(program.id)[0]).to eq(program_phase)
    end
  end

  describe ".get_submittable_assessments" do
    it "returns program phases names" do
      assessment = Program.get_submittable_assessments(program.id)
      expected_assessment = Program.joins(:phases, phases: :assessments).
                            where(id: program.id).
                            where.not(assessments: {
                                        expectation: "N/A"
                                      })

      expect(assessment).to eq(expected_assessment)
    end
  end
end
