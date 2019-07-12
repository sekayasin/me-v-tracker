require "rails_helper"
require "spec_helper"
require "helpers/learning_ecosystem_helper_spec"

describe "Learner program feedback popup modal" do
  include LearnerProfileHelper

  include LearningEcosystemHelper
  before :all do
    center = create(:center)
    program = create(:program)
    @nps_question = create(:nps_question)
    @bootcamper = create :bootcamper
    cycle_center = create(:cycle_center, :ongoing, center: center)
    @learner_program = create :learner_program,
                              camper_id: @bootcamper[:camper_id],
                              cycle_center: cycle_center,
                              program_id: program.id
    create(
      :schedule_feedback,
      nps_question_id: @nps_question.nps_question_id,
      cycle_center_id: cycle_center.cycle_center_id,
      program_id: program.id
    )
  end

  feature "Learner View" do
    before :each do
      stub_non_andelan_bootcamper(@bootcamper)
      stub_current_session_bootcamper(@bootcamper)
      visit("/")
      sleep 1
      ProgramFeedbackPopupJob.perform_now
    end

    it "can view feedback schedule modal" do
      find("#learner-feedback-popup-modal")
      find(".emoji-ratings")
      find(".show-again-checkbox")
      expect(page).
        to have_content(@nps_question.question)
      expect(page).to have_content("Don't show this again.")
      first(".feedback-emoji").click
      find("#popup-textarea")
      find(".show-again-checkbox").click
      find(".close-feedback-popup-modal").click
      expect(page).to have_content("The popup won't show again.")
    end

    it "can't view feedback popup after opting out" do
      visit current_path
      expect(page).
        to have_no_content("How likely are you to recommend")
      expect(page).to have_no_content("Don't show this again.")
    end
  end
end
