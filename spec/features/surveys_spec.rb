require "rails_helper"
require "spec_helper"

describe "Survey page test" do
  before :all do
    @bootcamper1 = create(:bootcamper)
    @bootcamper2 = create(:bootcamper)
    @cycle_center1 = create(:cycle_center)
    @cycle_center2 = create(:cycle_center)
    @learner_program1 = create(
      :learner_program,
      camper_id: @bootcamper1.camper_id,
      cycle_center_id: @cycle_center1.cycle_center_id
    )
    @learner_program2 = create(
      :learner_program,
      camper_id: @bootcamper2.camper_id,
      cycle_center_id: @cycle_center2.cycle_center_id
    )
    @survey_pivot = create(
      :survey_pivot,
      surveyable: @cycle_center1
    )
  end

  feature "Learner View" do
    feature "View Survey Page With Surveys" do
      before(:each) do
        stub_non_andelan_bootcamper @bootcamper1
        stub_current_session_bootcamper @bootcamper1
        visit("/surveys")
      end

      scenario "a learner should be able to view their surveys" do
        expect(page).to have_content("In progress")
        expect(page).to have_content("Time to Completion")
        expect(page).to have_content(@survey_pivot.survey.title)
        expect(page).not_to have_content("No data to show :(")
      end
    end

    feature "View Survey Page Without Surveys" do
      before(:each) do
        stub_non_andelan_bootcamper @bootcamper2
        stub_current_session_bootcamper @bootcamper2
        visit("/surveys")
      end

      scenario "the learner should be informed when they have no surveys" do
        expect(page).to have_content("No data to show :(")
      end
    end
  end

  feature "LFA/Observer View" do
    before(:each) do
      clear_session
      stub_andelan_non_admin
      stub_current_session_non_admin
      visit("/surveys")
    end

    scenario "it redirects to index route if not a learner or Admin" do
      expect(current_path).to eq("/")
    end
  end

  feature "Admin View" do
    before(:each) do
      stub_admin_data_success
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/surveys")
    end

    feature "View Survey page" do
      scenario "user should be able to view the survey page" do
        expect(page).to have_selector("#main-survey-section")
        expect(page).to have_selector(".main-header")
        expect(page).to have_content("Surveys")
      end

      scenario "user should be able to view the create survey modal" do
        find("#new-survey-btn").click
        expect(page).to have_content("Create Survey")
        expect(page).to have_content("Survey Title")
        expect(page).to have_content("Link to Survey")
        expect(page).to have_content("Survey Recipients")
        expect(page).to have_field("title")
        expect(page).to have_field("link")
        expect(page).to have_selector(".create-survey-btn")
        expect(page).to have_content("From")
        expect(page).to have_content("To")
      end

      scenario "user should be able to view the edit survey modal" do
        first(".edit-icon").click
        expect(page).to have_content("Edit Survey")
        expect(page).to have_content("Survey Title")
        expect(page).to have_content("Link to Survey")
        expect(page).to have_content("Survey Recipients")
        expect(page).to have_content("Update")
        expect(page).to have_selector(".update-survey-btn")
      end
    end

    feature "Create new survey" do
      scenario "user should be able to create new survey" do
        find("a#new-survey-btn").click
        expect(page).to have_content("Create Survey")
        fill_in("title", with: "VOF Sample Survey")
        fill_in("link", with: "https://google_survey_form.com")
        find(".create-survey-form span.ui-selectmenu-text").click
        find("li#ui-id-3").click
        fill_in("select_start_date_survey", with: "12 Dec 2018 10:29")
        fill_in("select_end_date_survey", with: "18 Dec 2018 10:29")
        find("#create-survey-button").click
        expect(page).to have_content("Survey successfully created")
      end

      scenario "user should get error when form validation fails" do
        find("a#new-survey-btn").click
        expect(page).to have_content("Create Survey")
        fill_in("title", with: "VOF Sample Survey")
        fill_in("link", with: "https://google_survey_form.com")
        fill_in("select_start_date_survey", with: "12 Dec 2018 10:29")
        fill_in("select_end_date_survey", with: "18 Dec 2018 10:29")
        find("#create-survey-button").click
        expect(page).to have_content("Recipients not selected")
      end

      scenario "user should get error when form validation fails" do
        find("a#new-survey-btn").click
        find("span.ui-selectmenu-text").click
        fill_in("title", with: "VOF Survey")
        fill_in("link", with: "Invalid Link")
        find("li#ui-id-3").click
        fill_in("select_start_date_survey", with: "12 Dec 2018 10:29")
        fill_in("select_end_date_survey", with: "18 Dec 2018 10:29")
        find("#create-survey-button").click
        expect(page).to have_content("Survey link provided is not valid")
      end

      scenario "user should get error when form validation fails" do
        find("a#new-survey-btn").click
        expect(page).to have_content("Create Survey")
        fill_in("title", with: "VOF Survey")
        fill_in("link", with: "https://google_survey_form.com")
        find(".create-survey-form span.ui-selectmenu-text").click
        find("li#ui-id-3").click
        fill_in("select_start_date_survey", with: "12 Dec 2018 10:29")
        find("#create-survey-button").click
        expect(page).to have_content("All fields are required")
        expect(page).to have_content("Invalid end date")
      end

      scenario "user should get error when end date is less than start date" do
        find("a#new-survey-btn").click
        fill_in("title", with: "VOF Sample Survey")
        fill_in("link", with: "https://google_survey_form.com")
        find(".create-survey-form span.ui-selectmenu-text").click
        find("li#ui-id-3").click
        fill_in("select_start_date_survey", with: "12 Dec 2018 10:29")
        fill_in("select_end_date_survey", with: "07 Dec 2018 10:29")
        find("#create-survey-button").click
        expect(page).to have_content("End date must be greater than start date")
      end
    end

    feature "Update survey" do
      scenario "user should be able to update a survey" do
        first(".edit-icon").click
        fill_in("title", with: "Updated test survey")
        expect(page).to have_content("Edit Survey")
        fill_in("select_start_date_survey", with: "15 Dec 2018 10:29")
        fill_in("select_end_date_survey", with: "18 Dec 2018 10:29")
        find("#update-survey-button").click
        expect(page).to have_content("Survey updated successfully")
      end
    end

    feature "duplicate survey" do
      scenario "user should be able to duplicate a survey" do
        first(".copy-icon").click
        expect(page).to have_content("Duplicate")
        find("#create-survey-button").click
        expect(page).to have_content("Survey successfully created")
      end
    end

    feature "Close survey" do
      scenario "admin can close survey" do
        expect(page).to have_no_content("Completed")
        expect(page).to have_css(".switch")
        expect(page).to have_css(".edit-icon")
        first(".switch").click
        modal_header = first(".confirmation-header")
        expect(modal_header).to have_content("Confirm Closure")
        expect(page).to have_css(".cancel-btn", count: 1)
        expect(page).to have_css(".btn-submit", count: 1)
        first(".btn-submit").click
        expect(page).to have_content("Survey closed successfully")
      end
    end

    feature "Delete survey" do
      scenario "admin can delete survey" do
        expect(page).to have_no_content("Completed")
        expect(page).to have_css(".trash-icon")
        first(".trash-icon").click
        modal_header = first(".confirmation-header")
        expect(modal_header).to have_content("Confirm Delete")
        expect(page).to have_css(".cancel-btn", count: 1)
        expect(page).to have_css(".btn-submit", count: 1)
        first(".btn-submit").click
        expect(page).to have_content("Survey deleted successfully")
      end
    end
  end
end
