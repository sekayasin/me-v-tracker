require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper"

describe "Survey 2.0 setup page" do
  before :each do
    stub_admin_data_success
    stub_andelan
    stub_current_session
    select_program
    visit "/surveys-v2/setup"
  end
  before :all do
    @bootcamper1 = create(:bootcamper)
    @cycle_center1 = create(:cycle_center)
    @learner_program1 = create(
      :learner_program,
      camper_id: @bootcamper1.camper_id,
      cycle_center_id: @cycle_center1.cycle_center_id
    )
    @survey_pivot = create(
      :survey_pivot,
      surveyable: @cycle_center1
    )
  end

  feature "Create new survey" do
    scenario "users should see the page to create survey" do
      assert_content %W(Create\ a\ Survey Survey\ Preview SECTION\ 1)
      assert_selectors(
        %w(#add-survey-description-btn
           #add-question-btn-0
           #add-section-btn-0
           #survey-share-btn)
      )
    end

    scenario "users can create a survey multi-choice question type" do
      populate_question_helper("2")
      fill_in("Type Your Question...", with: "This is a multichoice question")
      fill_in("Add A Choice", with: "multichoice1")
      find(".add-choice").native.send_keys(:return)
      fill_in("Add A Choice", with: "multichoice2")
      find(".add-choice").native.send_keys(:return)
      expect(page).to have_selector(".question-wrapper")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users should get a validation error when they share survey" do
      populate_question_helper("2")
      fill_in("Type Your Question...", with: "")
      find("#survey-share-btn").click
      expect(page).to have_content("Question 1 cannot be empty.")
      expect(page).
        to have_content("Question 1 must contain at least two (2) options.")
      add_section
      expect(page).to have_content("SECTION 2")
    end

    scenario "users should get a validation error when they share survey" do
      populate_question_helper("2")
      fill_question_with("new")
      fill_in("Add A Choice", with: "point")
      find(".add-choice").native.send_keys(:return)
      find("#survey-share-btn").click
      expect(page).
        to have_content("Question 1 must contain at least two (2) options.")
      add_section
      expect(page).to have_content("SECTION 2")
    end

    scenario "users can create checkboxes question type" do
      populate_question_helper("3")
      fill_question_with("checkbox")
      add_choice
      expect(page).to have_selector(".question-wrapper")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create dropdown question type" do
      populate_question_helper("4")
      fill_question_with("dropdown")
      add_choice
      expect(page).to have_selector(".question-wrapper")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create scale question type" do
      populate_question_helper("5")
      fill_question_with("scale")
      find(".mdl-slider").set(6).click
      expect(page).to have_selector("li", count: 5)
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create multi-choice grid question type" do
      populate_question_helper("6")
      fill_question_with("multi-choice-grid")
      add_row_and_column
      expect(page).to have_selector(".question-wrapper")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create check-box grid question type" do
      populate_question_helper("7")
      fill_question_with("checkbox-grid")
      add_row_and_column
      expect(page).to have_selector(".question-wrapper")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create date question type without date limits" do
      populate_question_helper("8")
      fill_question_with("date")
      expect(page).to have_selector(".select-date")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create date question type with date limits" do
      populate_question_helper("8")
      fill_question_with("date")
      expect(page).to have_selector(".select-date")
      page.execute_script("$('.min-date').val('2019-05-17')")
      page.execute_script("$('.max-date').val('2019-05-25')")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create time question type" do
      populate_question_helper("9")
      fill_question_with("time")
      expect(page).to have_selector(".main-display")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create paragraph question type" do
      populate_question_helper("10")
      fill_question_with("paragraph")
      expect(page).to have_selector("#text-box")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create picture options question type" do
      populate_question_helper("11")
      fill_question_with("options")
      upload_images
      expect(page).to have_selector(".option-image-list-item")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "users can create picture checkbox question type" do
      populate_question_helper("12")
      fill_question_with("checkbox")
      upload_images
      expect(page).to have_selector(".checkbox-image-list-item")
      save_survey
      expect(page).to have_content("Successfully created survey")
    end

    scenario "pop error message if the survey schedule is invalid" do
      populate_question_helper("7")
      fill_question_with("checkbox-grid")
      add_row_and_column
      save_survey_with_invalid_schedule
      expect(page).to have_content(
        "End date must be ahead of start date"
      )
    end
  end
end
