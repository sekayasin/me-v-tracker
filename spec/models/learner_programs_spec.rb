require "rails_helper"

RSpec.describe LearnerProgram, type: :model do
  let(:learner_program) { create :learner_program }

  context "Associations" do
    it { is_expected.to have_many(:output_submissions) }
    it { is_expected.to have_many(:scores) }
    it { is_expected.to have_many(:decisions) }
    it { is_expected.to have_many(:decision_reasons) }
    it { is_expected.to have_many(:feedback) }
    it { is_expected.to have_many(:holistic_evaluations) }
    it { is_expected.to have_many(:program_years) }
    it { is_expected.to belong_to(:program) }
    it { is_expected.to belong_to(:dlc_stack) }
  end

  describe ".lfas" do
    context "when given non-existent location and/or cycle" do
      it "returns empty result" do
        expect(LearnerProgram.lfas("Abuja", "10")).to be_empty
      end
    end

    context "when given valid location and cycle" do
      let(:cycle) { create(:cycle, cycle: 10) }
      let(:center) { create(:center, name: "Lagos") }
      let(:cycle_center) { create(:cycle_center, cycle: cycle, center: center) }

      it "returns all week1 LFAs" do
        lfas = []
        5.times do
          lfas <<
            create(:learner_program, cycle_center: cycle_center).
            week_one_facilitator
        end
        expect(LearnerProgram.lfas("Lagos", "10").sort).to eq lfas.sort
      end
    end
  end

  describe ".update_campers_progress" do
    let(:learner_program) { create :learner_program }

    context "when creating a bootcamper" do
      it "has empty value for progress" do
        expect(learner_program.progress).to be_nil
      end
    end

    context "when given valid argument" do
      let(:data) do
        {
          learner_program_id: learner_program.id,
          score: 34,
          total: 42
        }
      end

      it "updates a camper's progress" do
        LearnerProgram.update_campers_progress(data)
        updated_camper = LearnerProgram.find_by(id: learner_program.id)

        expect(updated_camper.progress).to eq 80
      end
    end
  end

  describe ".get_existing_program" do
    let(:program) { create :program }
    let(:learner_program) { create :learner_program, program: program }
    context "when the program is in the database" do
      it "returns a pre-existing program" do
        pre_existing_program = LearnerProgram.get_existing_program(
          program.id,
          learner_program.cycle_center.center.name,
          learner_program.cycle_center.cycle.cycle
        )
        expect(pre_existing_program).to eql(learner_program)
        expect(pre_existing_program.
          cycle_center.center.country).to eql(
            learner_program.cycle_center.center.country
          )
      end
    end

    context "when the program is not in the database" do
      it "returns nil" do
        pre_existing_program = LearnerProgram.get_existing_program(
          program.id,
          "Somewhere in pluto",
          learner_program.cycle_center.cycle.cycle
        )
        expect(pre_existing_program).to eql(nil)
      end
    end
  end

  describe ".locations" do
    include_context "learner program details"

    context "when given valid program id" do
      it "returns all locations with no duplicates" do
        expect(LearnerProgram.program_locations(program.id).length).to eq(1)
      end
    end

    context "when given invalid program id" do
      it "returns no location" do
        expect(LearnerProgram.program_locations(0).length).to eq(0)
      end
    end
  end

  describe ".cycles" do
    include_context "learner program details"

    context "when given valid city" do
      it "returns the cycles" do
        expect(LearnerProgram.cycles(program.id, "New York")[0]).to eq(1)
      end
    end

    context "when given invalid city" do
      it "returns no cycle" do
        expect(LearnerProgram.cycles(program.id, "Ibandan").length).to eq(0)
      end
    end
  end

  describe ".get_phase_impression" do
    include_context "learner program details"

    it "returns phases associated to the learner and all impression" do
      phases_and_impressions = LearnerProgram.
                               get_phase_impression(learner_program.id)
      expect(phases_and_impressions.length).to eql 2
    end
  end

  describe ".get_all_learner_feedback" do
    let(:bootcamper) { create :bootcamper_with_learner_program }

    it "returns programs linked to the email in the LearnerProgram table" do
      programs = LearnerProgram.get_all_learner_feedback(bootcamper.email)
      expect(programs.camper_id).to eql bootcamper.camper_id
    end
  end

  describe ".get_all_learner_programs" do
    let(:bootcamper) { create :bootcamper_with_many_learner_program }

    it "returns all programs for the camper" do
      programs = LearnerProgram.get_learner_programs(bootcamper.camper_id)
      learner_programs = LearnerProgram.where(camper_id: bootcamper.camper_id)
      expect(programs.length).to eql learner_programs.length
    end
  end

  describe ".can_be_evaluated" do
    include_context "eligibility context"

    context "when an admin or lfa has not submitted enough evaluations" do
      it "returns true" do
        eligible = learner_program.can_be_evaluated?

        expect(eligible).to eq true
      end
    end

    context "when an admin or lfa has submitted enough evaluations" do
      let!(:new_holistic_evaluations) do
        create_list(
          :holistic_evaluation,
          2,
          learner_program_id: learner_program.id,
          evaluation_average: evaluation_average
        )
      end

      it "returns false" do
        eligible = learner_program.can_be_evaluated?

        expect(eligible).to eq false
      end
    end
  end
end
