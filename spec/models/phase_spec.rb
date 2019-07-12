require "rails_helper"

RSpec.describe Phase, type: :model do
  include PhaseSpecHelper
  let!(:cycle_center) do
    create :cycle_center, start_date: Date.parse("2018-9-11")
  end
  let!(:week_end_cycle_center) { create :cycle_center, :weekend_start_date }
  let!(:phase) { create :phase, phase_duration: 1, name: "Andela ALC" }
  let!(:phases) { create_list :phase, 5 }

  describe "Phase Associations" do
    it { is_expected.to have_and_belong_to_many(:assessments) }
    it { is_expected.to have_many(:scores) }
    it { is_expected.to have_many(:feedback) }
    it { is_expected.to have_many(:output_submissions) }
  end

  describe ".find_or_create_phase" do
    it "returns created phases" do
      phases = Phase.find_or_create_phase(["first phase", "second phase"])
      created_phase = Phase.last(2)

      expect(phases[0]).to eq(created_phase[0].name)
      expect(phases[1]).to eq(created_phase[1].name)
    end
  end

  describe "get_phase_due_date" do
    it "returns the correct phase due-date" do
      phases.each do |phase|
        expect(get_the_current_due_date(
                 phase, cycle_center
               )).to eq get_expected_due_date(phase, cycle_center)
      end
    end
    it "returns the correct day if start date is a weekend" do
      expect(get_the_current_due_date(
               phase, week_end_cycle_center
             )).to eq "September 03, 2018"
    end
  end
end
