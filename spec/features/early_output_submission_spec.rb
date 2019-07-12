require "rails_helper"
require "spec_helper"

describe "Learning ecosystem test" do
  include LearnerProfileHelper

  before :all do
    program = create(:program)
    @bootcamper = create :bootcamper
    facilitator = create :facilitator
    cycle_center = create(:cycle_center, :submission_on_time)
    @learner_program = create :learner_program,
                              camper_id: @bootcamper[:camper_id],
                              cycle_center: cycle_center,
                              program_id: program.id,
                              week_one_facilitator_id: facilitator.id
    @phase = create(:phase)
    create :programs_phase, phase_id: @phase.id,
                            program_id: program.id
    @framework_criterium = create :framework_criterium
    @assessment = create :assessment, :requires_submissions, :long_description,
                         phases: [@phase],
                         framework_criterium_id: @framework_criterium.id
    create :output_submission,
           learner_program: @learner_program,
           phase: @phase,
           assessment: @assessment
    @assessments = populate_assessments
  end

  feature "Submissions on correct due date" do
    scenario "Leaner sees no lateness text for on-time submissions" do
      stub_non_andelan_bootcamper(@bootcamper)
      stub_current_session_bootcamper(@bootcamper)
      visit("/learner/ecosystem")
      sleep 1
      enter_submission
      find("button#submit-for-#{@assessments[:dual_submission].id}").click
      expect('<div class="lfa-view-late-submission">').to have_content("")
    end

    xscenario "LFA sees no lateness text for on-time submissions" do
      stub_andelan
      stub_current_session
      visit("/")
      click_on "Select ALC"
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      click_on "Submissions"
      click_on @bootcamper.name
      click_on @framework_criterium.framework.name
      click_on "View Submission"
      expect('<div class="lfa-view-late-submission">').to have_content("")
    end
  end
end
