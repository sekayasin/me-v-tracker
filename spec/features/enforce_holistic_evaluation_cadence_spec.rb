require "rails_helper"
require "spec_helper"

describe "Learner's Page" do
  include HolisticEvaluationHelper

  before :all do
    @program = Program.first
    @cycle_center = create(:cycle_center, program_id: @program.id)
    @bootcamper = create(:bootcamper)
    @learner_program = create(
      :learner_program,
      program_id: @program.id,
      camper_id: @bootcamper.id,
      cycle_center_id: @cycle_center.id
    )
  end

  before(:each) do
    go_to_profile_page
  end

  after :all do
    HolisticEvaluation.delete_all
    LearnerProgram.where(
      "id = #{@learner_program.id} or camper_id = '#{@bootcamper.camper_id}'"
    ).delete_all
    EvaluationAverage.delete_all
    Bootcamper.where("camper_id = '#{@bootcamper.camper_id}'").delete_all
  end

  feature "No Holistic Evaluation submitted" do
    scenario "Profile shows zero holistic evaluations" do
      holistic_evaluations_received = find(
        "#holistic_evaluations_received"
      ).text
      expect(holistic_evaluations_received).to eq("0")
    end
  end

  feature "Required number of holistic evaluations reached" do
    scenario "Error notification is displayed" do
      2.times do
        submit_holistic_evaluation
        expect(page).to have_content("Holistic evaluation successfully saved")
      end

      expect(page).to have_content(
        "You have completed all required evaluations for this learner"
      )

      expect_limit_warning

      expect_disabled_modal
    end

    scenario "Profile shows two holistic evaluations" do
      holistic_evaluations_received = find(
        "#holistic_evaluations_received"
      ).text
      expect(holistic_evaluations_received).to eq("2")
    end
  end
end
