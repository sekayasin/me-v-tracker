require "rails_helper"
require "spec_helper"
require_relative "../support/survey_v2_respond_helper"

describe "Survey 2.0 respond page for users" do
  before :all do
    create_respond_bootcamper
    @survey = create(:new_survey, :published)
    prepare_optional_question
  end

  before(:each) do
    stub_non_andelan_bootcamper(@bootcamper)
    stub_current_session_bootcamper(@bootcamper)
    visit "/surveys-v2/respond/#{@survey.id}"
  end

  feature "Respond to a survey" do
    scenario "responses page" do
      expect(current_path).to eq("/surveys-v2/respond/#{@survey.id}")
    end

    scenario "See the various sections" do
      expect(page).to have_content(@survey.title.upcase)
      expect(page).to have_content("SECTION 1")
      expect(page).to have_content("Next")
      expect(page).not_to have_content("Submit")
    end

    scenario "Switch between question using next button" do
      find("#next-preview").click
      expect(page).to have_content(@survey.title.upcase)
      expect(page).to have_content("SECTION 2")
      expect(page).not_to have_content("Next")
      expect(page).to have_content("Prev")
      expect(page).to have_content("Submit")
    end

    scenario "Switch the previous section using previous button" do
      find("#next-preview").click
      expect(page).to have_content("Submit")
      find("#prev-preview").click
      expect(page).not_to have_content("Submit")
      expect(page).to have_content("SECTION 1")
    end

    scenario "show optional section" do
      expect(page).not_to have_selector(".time_wrapper")
      within ".answer:nth-child(1)" do
        find("input", visible: false).click
      end
      expect(page).to have_selector(".time-wrapper")
    end

    scenario "fill optional section" do
      within ".answer:nth-child(1)" do
        find("input", visible: false).click
      end
      within ".time-wrapper" do
        first(".display-time").set("10")
        find(".display-time:nth-child(2)").set("59")
      end
      expect(page).to have_selector(".question-content")
      expect(page).to have_selector(".display-time")
      expect(page).to have_content("Next")
    end

    scenario "show modal when an option is changed" do
      within ".answer:nth-child(1)" do
        find("input", visible: false).click
      end

      expect(page).to have_selector(".time-wrapper")
      within ".answer:nth-child(2)" do
        find("input", visible: false).click
      end
      expect(page).to have_content("Confirm Option Change")
      expect(page).to have_content("The linked section and your answers")
    end

    scenario "Retain question when cancel is clicked on modal" do
      answer_multichoice_question
      find(".close-option-change").click
      expect(page).to have_selector(".time-wrapper")
    end

    scenario "Clear question if Continue is clicked" do
      answer_multichoice_question
      find("#confirm-option-change").click
      expect(page).not_to have_selector(".time-wrapper")
    end

    scenario "Gives error if required questions are not filled" do
      find("#next-preview").click
      find(".respond-submit-btn").click
      expect(page).to have_content("Please fill in at least one option")
    end

    scenario "Gives error if optional question is not filled" do
      answer_question(1)
      expect(page).to have_content("Please fill all the required questions")
    end

    scenario "Gives error if invalid time is given" do
      within ".answer:nth-child(1)" do
        find("input", visible: false).click
      end
      within ".time-wrapper" do
        first(".display-time").set("59")
      end
      expect(page).to have_content("Please enter a valid time")
    end

    scenario "Submit user response when there is no optional section" do
      answer_question(2)
      expect(page).to have_content("Response Successfully Submitted")
    end

    scenario "Submit user response with optional section" do
      submit_user_response
      expect(page).to have_content("Response Successfully Submitted")
    end
  end
end
