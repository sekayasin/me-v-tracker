require "rails_helper"
require "spec_helper"
require "helpers/learning_ecosystem_helper_spec"

describe "Learning ecosystem test" do
  include LearnerProfileHelper
  include LearningEcosystemHelper
  before :all do
    set_up_db
    set_up_gcp
    @time_now = Time.now
  end

  before :each do
    stub_non_andelan_bootcamper(@bootcamper)
    stub_current_session_bootcamper(@bootcamper)
    visit("/learner/ecosystem")
  end

  feature "displays overview and phases tab" do
    scenario "user should see phases outputs" do
      find("a#overview-item").click
      find("a#accordion-title-week-1").click
      expect(page).to have_selector(".phases-text")
    end
  end

  feature "display progress bars" do
    scenario "user should see a progress bar" do
      find("a#overview-item").click
      find("a#accordion-title-week-1").click
      expect(page).to have_selector(".progress-bar")
    end

    scenario "user should see a yellow progress bar" do
      find("a#overview-item").click
      find("a#accordion-title-week-1").click
      expect(page).to have_selector(".yellow-progress-bar")
    end

    scenario "user should see the progress of submitted outputs" do
      find("a#phases-tab").click
      find("a#accordion-title-#{@framework_criterium.framework_id}").click
      find("button#submit-for-#{@assessments[:dual_submission].id}").click
      expect(page).to have_selector(".drop-area")
      expect(page).to have_selector("#link")
      fill_in "link", with: "https://github.com"
      fill_in "description", with: "this is the description"
      upload_output_file("output_file.png")
      find("a#save-learner-submission").click
      expect(page).to have_content("Output submitted successfully")
      find("a#overview-tab").click
      expect(page).to have_content("1 of 9 (11%)")
    end

    scenario "user should see the phases with the corresponding headings" do
      find("a#overview-item").click
      expect(page).to have_selector(".progress-bar")
      find("a#accordion-title-week-1").click
      expect(page). to have_content("Phases")
      expect(page). to have_content("Progress")
      expect(page). to have_content("Submissions")
    end
  end

  feature "displays all phases" do
    scenario "user should see phases for a program and their assessments" do
      find("a#phases-tab").click
      expect(page). to have_content(@phase.name)
      find("a#accordion-title-#{@framework_criterium.framework_id}").click
      expect(page).to have_content(@assessment.name)
    end

    scenario "user should see the holistic evaluation comments" do
      find("a#phases-tab").click
      expect(page). to have_content(@phase.name)
      find("a#accordion-title-#{@framework_criterium.framework_id}").click
      expect(page).to have_content("Show more")
      first("a.show-more-link").click
      expect(page).to have_content("Show less")
      first("a.show-more-link").click
    end

    scenario "user should be able to view the feedback modal" do
      find("a#phases-tab").click
      find("a#accordion-title-#{@framework_criterium.framework_id}").click
      expect(page).to have_content("LFA Feedback")
    end
  end

  feature "learner can view outputs" do
    scenario "user can view outputs submitted" do
      enter_submission
      find("button#submit-for-#{@assessments[:dual_submission].id}").click
      expect(page).to have_content("View Submission")
      expect(page).to have_content("output_file.png")
      expect(page).to have_content("Enter a description")
    end
  end

  feature "learner update submitted output" do
    scenario "user can edit and update submitted output" do
      find("a#phases-tab").click
      find("a#accordion-title-#{@framework_criterium.framework_id}").click
      find("button#submit-for-#{@assessments[:dual_submission].id}").click
      expect(page).to have_content("View Submission")
      fill_in "link", with: ""
      fill_in "description", with: ""

      find("a#save-learner-submission").click
      error = "Please enter a description for your submission"
      expect(page).to have_content(error)

      fill_in "link", with: "https://the_submtted_file_link.com"
      fill_in "description", with: "Once upon a time"

      find("a#save-learner-submission").click
      expect(page).to have_content("Output successfully updated")
    end

    scenario "user can edit and update submitted output " do
      find("a#phases-tab").click
      find("a#accordion-title-#{@framework_criterium.framework_id}").click
      find("button#submit-for-#{@assessments[:dual_submission].id}").click
      expect(page).to have_content("View Submission")

      fill_in "link", with: "https://the_submtted_file_link.com"
      fill_in "description", with: "Once upon a time in wonderland"
      find("a#save-learner-submission").click
      expect(page).to have_content("Output successfully updated")
    end
  end

  feature "displays all learning outcome" do
    scenario "user should see learning outcome for a phase" do
      find("a#phases-tab").click
      expect(page). to have_content("Values Alignment")
      expect(page). to have_content("Output Quality")
      expect(page). to have_content("Feedback")
      find("a#accordion-title-#{@framework_criterium.framework_id}").click
      expect(page). to have_content("Learning Outcomes")
      expect(page). to have_content("Description")
      expect(page). to have_content("Outputs")
      expect(page). to have_content("Due Date")
      expect(page). to have_content("Action")
      expect(page). to have_content("LFA Feedback")
    end
  end

  feature "Learner outcomes should be configurable" do
    scenario "when a learning outcome is set to require a file upload" do
      enter_submission
      find("#submit-for-#{@assessments[:upload_submission].id}").click
      expect(page).to have_selector(".drop-area")
      expect(page).not_to have_selector("#link")
    end

    scenario "when a learning outcome is set to require a link" do
      enter_submission
      find("#submit-for-#{@assessments[:link_submission].id}").click
      expect(page).not_to have_selector(".drop-area")
      expect(page).to have_selector("#link")
    end

    scenario "when no submission type is specified for a particular outcome" do
      enter_submission
      find("#submit-for-#{@assessment.id}").click
      expect(page).not_to have_selector(".drop-area")
      expect(page).not_to have_selector("#link")
      expect(page).to have_selector("#description")
    end
  end

  feature "Learner can identify late submissions" do
    xscenario "User can identify a late submission" do
      enter_submission
      click_on "View Submission"
      submitted_on = @time_now.localtime
      submitted_on = submitted_on.strftime("%a %b %d %Y %H:")
      expected_error = "Submitted on: #{submitted_on}"
      expect(find(".lfa-view-late-submission").text).to include(expected_error)
    end
  end

  feature "Learner can submit many outputs for one outcome" do
    scenario "user can submit outcome for first day of one phase" do
      enter_submission
      fill_in_link("Day 1", "https://github.com")
      expect(page).to have_content("Output submitted successfully")
    end

    xscenario "learner edits multi-phased submitted output" do
      enter_submission
      fill_in_link("Day 1", "https://vof.andela.com")
      expect(page).to have_content("Output successfully updated")
    end

    xscenario "learner can submit for second day of one phase" do
      enter_submission
      fill_in_link("Day 2", "https://vof.andela.com")
      expect(page).to have_content("Output submitted successfully")
    end
  end
  feature "learner can submit reflection to lfa feedback" do
    xscenario "after successful submission button changes to update" do
      find("a#phases-tab").click
      find("a#accordion-title-#{@framework_criterium.framework_id}").click
      first(".view-lfa-btn").click
      sleep(5)
      click_on "Write Reflection"
      expect(page).to have_content("Submit Reflection")
      sample_reflection = Faker::Lorem.paragraph
      fill_in "reflection", with: sample_reflection, id: "reflection"
      click_on "Submit Reflection"
      first(".view-lfa-btn").click
      click_on "View Reflection"
      expect(page).to have_content("Update Reflection")
    end
  end
end
