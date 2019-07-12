require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper.rb"

describe "Survey 2.0 index page" do
  before(:each) do
    stub_admin
    stub_current_session_admin
    select_program
  end
  before :all do
    @survey = create(:new_survey, :published)
    create(:survey_section, new_survey_id: @survey.id)
    collaborator = Collaborator.create(email: "juliet@andela.com")
    NewSurveyCollaborator.create(
      new_survey_id: @survey[:id],
      collaborator_id: collaborator[:id]
    )
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

  feature "Admin can edit a survey" do
    scenario "expect to see surveys when there are surveys" do
      visit("/surveys-v2/#{@survey.id}/edit")
      expect(page).to have_content("Share")
      expect(page).to have_selector("#add-question-btn-0")
      find("#add-question-btn-0").click
      populate_question_helper("5")
      fill_question_with("scale")
      find(".mdl-slider").set(6).click
      expect(page).to have_selector("li", count: 5)
      update_survey
    end

    scenario "cannot update survey with blank title" do
      visit("/surveys-v2/#{@survey.id}/edit")
      fill_in("Enter Title", with: "", exact: true)
      find("#survey-share-btn").click
      expect(page).to have_content("Please, enter a title for your survey.")
    end

    scenario "expect to have at least two options" do
      visit("/surveys-v2/#{@survey.id}/edit")
      expect(page).to have_content("Share")
      expect(page).to have_selector("#add-question-btn-0")
      populate_question_helper("2")
      fill_question_with("multiple-choices")
      fill_in("Add A Choice", with: "multichoice1", exact: true)
      find(".add-choice").native.send_keys(:return)
      find("#survey-share-btn").click
      expect(page).to have_content(
        "Question 1 must contain at least two (2) options."
      )
    end

    scenario "expect to have more than two columns" do
      visit("/surveys-v2/#{@survey.id}/edit")
      expect(page).to have_content("Share")
      expect(page).to have_selector("#add-question-btn-0")
      populate_question_helper("6")
      fill_question_with("multi-choice-grid")
      find("#survey-share-btn").click
      expect(page).to have_content(
        "Question 1 must contain at least two (2) columns."
      )
    end

    scenario "users can update multi-choice grid question" do
      first("#new-survey-btn").click
      sleep 1
      populate_question_helper("5")
      fill_question_with("scale")
      find(".mdl-slider").set(6).click
      expect(page).to have_selector(".question-wrapper")
      save_survey
      first(".survey-card .more-icon").hover
      first(".survey-card #edit-form").click
      expect(page).to have_content("Share")
      expect(page).to have_selector("#add-question-btn-0")
      populate_question_helper("6")
      fill_question_with("multi-choice-grid")
      add_row_and_column
      update_survey
    end

    scenario "users can update checkbox grid question" do
      populate_edit_survey
      sleep 1
      populate_question_helper("7")
      fill_question_with("checkbox-grid")
      add_row_and_column
      update_survey
    end
    scenario "users can update picture options question type" do
      populate_edit_survey
      populate_question_helper("11")
      fill_question_with("options")
      upload_images
      expect(page).to have_selector(".option-image-list-item")
      update_survey
    end
  end

  feature "Admin delete a survey" do
    # TODO: Fix this failing test
    xscenario "expect to see create a survey when there is no survey" do
      find("#surveys-v2-btn").click
      first(".survey-card").hover
      first(".survey-card .more-icon").hover
      first(".survey-card .delete").click
      first("#confirm-handle-survey").click
      expect(page).to have_content("Create a Survey")
      expect(NewSurvey.count).to be(0)
    end
  end
end

describe "Survey 2.0  page" do
  before(:each) do
    stub_admin
    stub_current_session_admin
    select_program
  end
  before :all do
    collaborator = Collaborator.find_or_create_by(email: "juliet@andela.com")
    40.times do
      @survey = create(:new_survey)
      NewSurveyCollaborator.create(
        new_survey_id: @survey[:id],
        collaborator_id: collaborator[:id]
      )
    end
  end

  feature "Admin can click on pagination button" do
    scenario "Admin should be able to see a pagination control" do
      expect(page).to have_css(".pagination-control")
      expect(page).to have_css(".main-pages")
      expect(page).to have_css(".page.active-page")
    end

    scenario "Admin should be able to navigate between pages" do
      next_button = find(".next")
      previous_button = find(".prev")
      sleep 1
      next_button.click
      next_button.click
      previous_button.click
      previous_button.click

      expect(page).to have_css(".prev-next.grey-out")
      expect(page).to have_css(".title")
      expect(page).to have_css(".time")
    end
  end
end
