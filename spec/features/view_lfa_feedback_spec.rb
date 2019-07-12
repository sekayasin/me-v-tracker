require "rails_helper"
require "spec_helper"
require "helpers/learning_ecosystem_helper_spec"

describe "personal feedback modal test" do
  include LearnerProfileHelper
  include LearningEcosystemHelper
  before :all do
    center = create(:center)
    program = create(:program)
    @bootcamper = create :bootcamper
    cycle_center = create(:cycle_center, center: center)
    @learner_program = create :learner_program,
                              camper_id: @bootcamper[:camper_id],
                              cycle_center: cycle_center,
                              program_id: program.id
    @learner_center = @learner_program.cycle_center.cycle_center_details

    @phases = Phase.all
    @phases.each do |phase|
      create :programs_phase, phase_id: phase.id,
                              program_id: program.id
    end
    @framework_criteriums = FrameworkCriterium.all
    @assessments = []
    @framework_criteriums.each do |framework_criterium|
      @phases.each do |phase|
        assessment = create :assessment,
                            :requires_submissions,
                            :long_description,
                            phases: [phase],
                            framework_criterium: framework_criterium
        create(
          :output_submission,
          learner_programs_id: @learner_program.id,
          phase_id: phase.id,
          assessment_id: assessment.id
        )
        create(
          :feedback,
          learner_program: @learner_program,
          phase: phase,
          assessment: assessment
        )
      end
    end
  end

  feature "Learner can navigate through phases" do
    before do
      stub_non_andelan_bootcamper(@bootcamper)
      stub_current_session_bootcamper(@bootcamper)
      visit("/learner/ecosystem")
      click_on "Phases"
      click_on "Values Alignment"
      first(".view-lfa-btn").click
    end
    scenario "User can view the modal details" do
      modal_header = first(".learner-feedback-header")
      expect(modal_header).to have_content("View Feedback")
      feedback_content_title = first(".feedback-content-title")
      expect(feedback_content_title).to have_content("Impression")
    end
    scenario "A selection in phase updates outputs" do
      find("#learner-feedback-phase-button").click
      find(".ui-menu-item", text: "Bootcamp").click
      find("#learner-feedback-output-button").click
      expect(first(".ui-menu-item")).to have_content("Excellence")
    end
    scenario "A user can view feedback for specific output" do
      find("#learner-feedback-phase-button").click
      find(".ui-menu-item", text: "Project Assessment").click
      find("#learner-feedback-framework-button").click
      find(".ui-menu-item", text: "Output Quality").click
      find("#learner-feedback-output-button").click
      find(".ui-menu-item", text: "Version Control").click
      impression = first(".feedback-impression")
      expect(impression).to have_content("No Impression")
      details = first(".feedback-content-text")
      expect(details).to have_content("No Feedback Available")
    end
  end
end
