require "rails_helper"

RSpec.describe ProgramsPhase, type: :model do
  describe "ProgramsPhase Association" do
    it { is_expected.to belong_to(:program) }
    it { is_expected.to belong_to(:phase) }
    it { is_expected.to have_many(:assessments).through(:phase) }
  end

  include_context "program phase context"

  describe ".get_phase_assessments_given_program_id" do
    it "returns program phases" do
      phase = ProgramsPhase.get_phase_assessments_given_program_id(program.id)
      expect(phase[0].assessments).to eq(programs_phase.phase.assessments)
    end
  end
end
