require "rails_helper"

RSpec.describe LearnersHelper, type: :helper do
  let!(:learner_program) { create :learner_program }
  let!(:inactive_learner_program) { create :learner_program, :inactive }
  let!(:active_learner_program) { create :learner_program, :ongoing }
  describe ".get_output_percentage" do
    it "display learner's overall percentage of 56" do
      overall_percentage = get_output_percentage(9, 16)
      expect(overall_percentage).to eql(56)
    end
  end
  describe ".get_history" do
    it "shows history of a v1.5 learner's bootcamps" do
      program = LearnerProgram.get_learner_programs(
        learner_program.camper_id
      ).first
      history = show_history(program)
      start_date = learner_program.cycle_center.start_date
      expect(history).to include(start_date.to_date.strftime("%a, %e %B %Y"))
    end
    it "shows Processing while program still ongoing" do
      program = LearnerProgram.get_learner_programs(
        active_learner_program.camper_id
      ).first
      history = show_history(program)
      expect(history).to include("Processing")
    end
    it "shows decision 6 or more working days after program end_date" do
      history = show_history(LearnerProgram.get_learner_programs(
        inactive_learner_program.camper_id
      ).first)
      expect(history).to include(inactive_learner_program.decision_two)
    end
  end
end
