# rubocop:disable Metrics/BlockLength
require "rails_helper"
require "spec_helper"
require "helpers/profile_helper"
require_relative "../support/profile_spec_helper.rb"

describe "Profile page test" do
  include ProfileHelper

  before :all do
    set_up
  end

  after :all do
    HolisticEvaluation.delete_all
  end

  before do
    profile_spec_helper
  end

  feature "view learners profile" do
    scenario "user should see uploaded camper data on the profile" do
      camper_name = @bootcamper.first_name + " " + @bootcamper.last_name
      expect(page).to have_content(camper_name)
    end

    scenario "user should see campers cycle" do
      cycle =
        @bootcamper.learner_programs.first.
        cycle_center.cycle_center_details[:cycle]
      expect(page).to have_content(cycle)
    end

    scenario "user should see campers email" do
      email = @bootcamper.email
      expect(page).to have_content(email)
    end

    scenario "user should see program history link" do
      expect(page).to have_content("View Program History")
    end

    scenario "user should see Verified Outputs" do
      verified_outputs_value = page.first(
        "p.key-detail", text: "Verified"
      ).find("span").text
      expect(page).to have_content("Verified: #{verified_outputs_value}")
    end

    scenario "user should see Holistic Evaluations received" do
      holistic_evaluations_received = find(
        "#holistic_evaluations_received"
      ).text
      expect(holistic_evaluations_received).to eq("0")
    end
  end

  feature "submit decision" do
    scenario "Admin should be able to submit a decision" do
      find("#decision-one-button").click
      find("#ui-id-13").click
      modal = first("#title-decision")
      expect(modal).to have_content("Decision Details")
      find("#decision-reason-select", text: "Other").click
      fill_in "Start Typing...", with: "Good work"
      find("a#decision-save").click
      sleep 1
      find("#decision-two-button").click
      find("#ui-id-28").click
      modal = first("#title-decision")
      expect(modal).to have_content("Decision Details")
      fill_in "Start Typing...", with: "Good work"
      find("#decision-reason-select", text: "Other").click
      find("a#decision-save").click
    end
  end

  feature "submit scores" do
    scenario "user should not be able to submit blank Comments field" do
      find("#phase-dropdown-button").click # filter by phase
      find("li", text: "Learning Clinic").click
      find("#framework-dropdown-button").click # filter by framework
      find("li", text: "Output Quality").click
      find("#criterium-dropdown-button").click # filter by criteria
      find("li", text: "Initiative").click
      sleep 1
      find("#assessment-rating-button").click # score
      find("li", text: "Below Expectations").click
      find("a#submit-score").click
      expect(page).to have_content("Comment(s) cannot be blank")
    end

    scenario "user should not be able to submit blank Score field" do
      find("#phase-dropdown-button").click # filter by phase
      find("li", text: "Learning Clinic").click
      find("#framework-dropdown-button").click # filter by framework
      find("li", text: "Output Quality").click
      find("#criterium-dropdown-button").click # filter by criteria
      find("li", text: "Initiative").click
      fill_in "Leave Comments", with: "More effort needed" # enter comment
      find("a#submit-score").click
      expect(page).to have_content("Score(s) cannot be blank")
    end

    scenario "user should be able to submit scores
                with necessary fields filled" do
      find("#phase-dropdown-button").click # filter by phase
      find("li", text: "Learning Clinic").click
      find("#framework-dropdown-button").click # filter by framework
      find("li", text: "Output Quality").click
      find("#criterium-dropdown-button").click # filter by criteria
      find("li", text: "Initiative").click
      sleep 1
      find("#assessment-rating-button").click # score
      find("li", text: "Below Expectations").click
      fill_in "Leave Comments", with: "More effort needed" # enter comment
      find("a#submit-score").click
      expect(page).to have_content("Assessment(s) recorded")
    end

    scenario "for scores 1 and 3 user should be able to submit scores
              without comments" do
      find("#phase-dropdown-button").click # filter by phase
      find("li", text: "Learning Clinic").click
      find("#framework-dropdown-button").click # filter by framework
      find("li", text: "Output Quality").click
      sleep 1
      find("#criterium-dropdown-button").click # filter by criteria
      find("li", text: "Initiative").click
      sleep 1
      find("#assessment-rating-button").click # score
      find("li", text: "At Expectations").click
      find("a#submit-score").click
      expect(page).to have_content("Assessment(s) recorded")
    end

    scenario "unauthorised user should not be able to submit scores" do
      stub_andelan_non_admin
      stub_current_session
      visit("/learners?program_id=4")
      expect(page.current_path).to eq analytics_path
      expect(page).to have_content(
        "Program Metrics"
      )
    end
  end

  feature "view program history" do
    scenario "user should see program history" do
      stub_andelan
      stub_current_session

      city =
        @second_learner_program.cycle_center.cycle_center_details[:city]
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link",
           text: @first_program.name).click

      find("img.proceed-btn").click
      click_on "Learners"
      camper_name = @bootcamper.first_name + " " + @bootcamper.last_name

      click_link(camper_name)
      find(".view-program-history").click
      find(".current-program").click
      expect(page).to have_content(city)
    end
  end

  feature "holistic evaluation modal" do
    scenario "user should see holistic evaluation modal" do
      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      modal = first("#holistic-performance")
      expect(modal).to have_content("View/Edit Scores History")
    end

    scenario "user should see default averages" do
      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click

      expect(page).to have_content("AVG: N/A")
    end

    scenario "user should see averages when evaluation is provided" do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find(
        "ul#index-dropdown li a.dropdown-link",
        text: @first_program.name
      ).click
      find("img.proceed-btn").click
      click_on "Learners"
      camper_name = @second_bootcamper.first_name + " " +
                    @second_bootcamper.last_name

      click_link(camper_name)

      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      expect(page).to have_content("AVG: 1")
    end

    xscenario "unauthorised user shouldn't submit holistic evaluation" do
      stub_andelan_non_admin
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      camper_name = @bootcamper.first_name + " " + @bootcamper.last_name
      click_link(camper_name)

      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      expect(page).not_to have_content("Submit")
    end
  end

  feature "score guide modal pops up" do
    scenario "user should be able to see scoring card info" do
      find(:css, ".icon-wrapper "\
      "span.material-icons.information-icon", match: :first).click
      sleep 1
      expect(page).to have_content(@metric.point.value)
    end
  end

  xfeature "decision status" do
    scenario "it shows user's current status " do
      expect(page).to have_content("Decision 1: In Progress")
      expect(page).to have_content("Decision 2: Not Applicable")
    end
  end
end

describe "LFA details test" do
  include ProfileHelper

  before :all do
    set_up
  end

  after :all do
    HolisticEvaluation.delete_all
  end

  before do
    profile_spec_helper
  end

  feature "lfa details" do
    scenario "it should show lfas assigned to the user" do
      learner_program_id = @bootcamper.learner_program_ids.first
      lfas = @bootcamper.learner_programs.where(
        id: learner_program_id
      )[0]
      week_one_lfa = lfas.week_one_facilitator.email
      week_two_lfa = lfas.week_two_facilitator.email
      expect(page).to have_content(week_one_lfa)
      expect(page).to have_content(week_two_lfa)
    end
  end

  feature "Only current phase should be editable " do
    scenario "Admin should be able to edit any of the output fields " do
      stub_andelan
      stub_current_session
      select_camper
      find("#phase-dropdown-button").click
      first(".ui-menu-item").click
      expect(first(".leave-comment")["disabled"]).to eq(nil)
    end

    xscenario "Only current phase outputs are editable with non-admins" do
      stub_andelan
      stub_current_session
      select_camper
      find("#phase-dropdown-button").click
      first(".ui-menu-item").click
      expect(first(".leave-comment")["disabled"]).to eq("true")
    end
  end
end
# rubocop:enable Metrics/BlockLength
