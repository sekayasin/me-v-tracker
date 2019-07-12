# rubocop:disable Metrics/BlockLength
require "rails_helper"
require "spec_helper"
require "helpers/submissions_helper_spec"

describe "Submissions page test" do
  RSpec.configure do |c|
    c.include SubmissionsHelper
  end
  before :all do
    first_db_setup
    second_db_setup
    @time_now = Time.now
    @unassigned_lp = create(
      :learner_program,
      program_id: @program.id,
      week_one_facilitator_id: create(:facilitator).id,
      week_two_facilitator_id: create(:facilitator).id
    )
  end

  feature "View submissions page" do
    scenario "user should be able to view the submissions page" do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
      expect(page).to have_selector("#submissions-page-container")
    end

    scenario "non-existent submission id should ridirect to 404 page" do
      stub_andelan
      stub_current_session
      visit("/submissions/non-exitent-id")
      expect(page).to have_selector("div.not-found")
    end

    scenario "bootcampers should not be able to view the submissions page" do
      stub_non_andelan_bootcamper @bootcamper
      stub_current_session_bootcamper @bootcamper
      visit("/submissions")
      # learner should be redirected to the learners page
      expect(page).to have_current_path(learner_path)
    end

    scenario "user should be able to navigate to phases page" do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
      first("a.learner-overview-container").click
      expect(page).to have_selector("#back-to-learners")
    end

    scenario "user should be able to navigate back to submissions page" do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
      first("a.learner-overview-container").click
      sleep 1
      find("img#back-to-learners").click
      expect(page).to have_selector(".learners-submission-container")
    end

    scenario "user should be able to view learning outcomes table" do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
      sleep 1
      first("a.learner-overview-container").click
      expect(page).to have_selector(".submission-learner-name")
      expect(page).to have_selector(".phases-tab")
      expect(page).to have_selector(".overview-bar")
      expect(page).to have_selector(".accordion-div")
      expect(page).to have_selector(".accordion-section-title")
      expect(page).to have_content("Duyile Oluwatomi")
    end

    scenario "user should be able to see framework" do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
      first("a.learner-overview-container").click
      expect(page).to have_content("Values Alignment")
      expect(page).to have_content("Output Quality")
      expect(page).to have_content("Feedback")
    end

    scenario "user should not be able to view unassigned submissions" do
      stub_andelan_non_admin
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit(submission_path(learner_program_id: @unassigned_lp.id))
      sleep 1
      expect(page).to have_selector("div.not-found")
    end
  end

  feature "View pending output review notificaton" do
    before :all do
      @output_submission = create(
        :output_submission,
        learner_program: @learner_program,
        phase_id: @phase.id,
        assessment_id: @assessment.id
      )
    end

    scenario "notification dot when a learner has unreviewed outputs" do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
      expect(page).to have_selector(".blue-dot")
    end
  end

  feature "No notification for reviewed outputs" do
    before :all do
      @feedback = create(
        :feedback,
        learner_program_id: @learner_program.id,
        phase_id: @phase.id,
        assessment_id: @assessment.id
      )
    end

    scenario "no notification dot when a learner has no unreviewed outputs" do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
      expect(page).not_to have_selector(".blue-dot")
    end
  end

  feature "Identify late submission" do
    before :all do
      @output_submission = create(
        :output_submission,
        learner_program: @learner_program,
        phase_id: @phase.id,
        assessment_id: @assessment.id,
        created_at: @time_now
      )
    end

    scenario "lfa identifies late submission" do
      stub_andelan
      stub_current_session
      visit("/")
      click_on "Select ALC"
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
      click_on @bootcamper.name
      sleep 1
      click_on @framework_criterium.framework.name
      click_on "View Submission"
      expect(page).to have_content("View Submission")
      time_ = @time_now.localtime
      today = time_.strftime("%a %b %d %Y %H:")
      mes = "Submitted on: #{today}"
      expect(find(".lfa-view-late-submission").text).to include(mes)
    end

    feature "learner reflection" do
      scenario "lfa is informed when a learner hasn't submitted reflection" do
        stub_andelan
        stub_current_session
        visit("/")
        click_on "Select ALC"
        find("ul#index-dropdown li a.dropdown-link").click
        find("img.proceed-btn").click
        visit("/submissions")
        click_on @bootcamper.name
        sleep 1
        click_on @framework_criterium.framework.name
        click_on "View Submission"
        find("li#reflection").click
        expect(page).not_to have_selector("textarea#learner-reflect")
        expect(page).to have_content("#{@bootcamper.first_name}"\
          " hasn't entered a reflection to your feedback yet")
      end

      feature "lfa view learner reflection" do
        before :all do
          @feedback = create(
            :feedback,
            learner_program_id: @learner_program.id,
            phase_id: @phase.id,
            assessment_id: @assessment.id
          )
          @reflection = create(
            :reflection,
            feedback_id: @feedback.id
          )
        end
        scenario "lfa can view submitted learner reflection" do
          stub_andelan
          stub_current_session
          visit("/")
          click_on "Select ALC"
          find("ul#index-dropdown li a.dropdown-link").click
          find("img.proceed-btn").click
          visit("/submissions")
          click_on @bootcamper.name
          sleep 1
          click_on @framework_criterium.framework.name
          click_on "View Submission"
          find("li#reflection").click
          expect(page).to have_content(@reflection.comment)
          expect(page).not_to have_content("#{@bootcamper.first_name}"\
          " hasn't entered a reflection to your feedback yet")
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
