require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper.rb"

describe "Survey 2.0 page test retain question options" do
  before :all do
    create_survey_bootcamper
  end

  before(:each) do
    stub_admin_data_success
    stub_andelan
    stub_current_session
    select_program
    goto_survey_page
  end

  before :all do
    @survey = create(:survey)
  end

  feature "Retain options when similar question is added" do
    scenario "it should preserve options for choice questions" do
      populate_question_helper("2")
      fill_question_with("multichoice question")
      add_choice
      change_question_helper("3")
      expect(page).to have_content("choice1")
      expect(page).to have_content("choice2")
      expect(page).to have_content("multichoice question")
      change_question_helper("4")
      fill_question_with("dropdown")
      expect(page).to have_no_content("multichoice question")
      expect(page).to have_content("dropdown")
      save_survey
    end

    scenario "it should preserve options for grid questions" do
      populate_question_helper("6")
      fill_question_with("multichoice grid")
      add_row_and_column
      expect(page).to have_content("row1")
      expect(page).to have_content("col2")
      change_question_helper("7")
      fill_question_with("checkbox grid")
      expect(page).to have_no_content("multichoice grid")
      expect(page).to have_content("checkbox grid")
      expect(page).to have_content("row1")
      expect(page).to have_content("col1")
      save_survey
    end

    scenario "it should not preserve options for non-related questions" do
      populate_question_helper("4")
      fill_question_with("dropdown question")
      add_choice
      change_question_helper("6")
      fill_question_with("Multichoice grid")
      add_row_and_column
      expect(page).to have_no_content("choice1")
      expect(page).to have_no_content("choice2")
      expect(page).to have_content("row1")
      expect(page).to have_content("col2")
      save_survey
    end

    scenario "it should preserve options for imag questions" do
      populate_question_helper("11")
      fill_question_with("choice images")
      upload_output_file("fullsizeoutput_3b copy.jpeg", "add-file-question-0")
      upload_output_file("fullsizeoutput_3b copy.jpeg", "add-file-question-0")
      change_question_helper("12")
      fill_question_with("checkbox images")
      expect(page).to have_no_content("choice images")
      expect(page).to have_content("checkbox images")
      expect(page).to have_selector(".checkbox-image-list-item")
      save_file("fullsizeoutput_3b copy")
      save_survey
    end
  end
end
