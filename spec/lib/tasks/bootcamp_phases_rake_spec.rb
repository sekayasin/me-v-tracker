require "rails_helper"
require "rake"

describe "app.rake" do
  before :all do
    Rake.application.rake_require "tasks/bootcamp_phases"
    Rake::Task.define_task(:environment)
  end

  describe "app:add_position_values_to_programs_phases" do
    let!(:program) do
      create :program, id: 4, name: "BootCamp v1.5"
    end
    let!(:phase1) { create :phase, id: 23, name: "On-boarding" }
    let!(:phase2) { create :phase, id: 24, name: "Self Learning" }
    let!(:phase3) { create :phase, id: 25, name: "Review" }
    let!(:phase4) { create :phase, id: 26, name: "Peer Learning" }
    let!(:phase5) { create :phase, id: 27, name: "Immersive" }
    let!(:phase6) { create :phase, id: 28, name: "Audit" }
    let!(:phase7) { create :phase, id: 29, name: "Pitch" }

    let(:run_rake_task) do
      Rake::Task["app:add_position_values_to_programs_phases"].reenable
      Rake.application.invoke_task "app:add_position_values_to_programs_phases"
    end

    context "when this task is invoked" do
      it "orders the bootcamp phases for v1.5 accordingly" do
        Phase.last(7).each do |phase|
          create :programs_phase, program_id: program.id, phase_id: phase.id
        end
        run_rake_task
        expect(ProgramsPhase.find_by(phase_id: 23).position).to eq 1
        expect(ProgramsPhase.find_by(phase_id: 24).position).to eq 2
        expect(ProgramsPhase.find_by(phase_id: 25).position).to eq 3
        expect(ProgramsPhase.find_by(phase_id: 29).position).to eq 7
      end
    end
  end
end
