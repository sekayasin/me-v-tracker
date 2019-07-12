require_relative "../support/survey_v2_feature_helper"

def before_each_go_to_surveys_page
  before(:each) do
    visit "/surveys-v2/setup"
  end
end

def initialize_survey_ui
  scenario "users should see the page to create survey" do
    expect_create_survey
    expect_form
    expect_section_1
    expect_add_suevey_button
    expect_add_question_button
    expect_add_section_button
    expect_share_button
  end
end

def survey_create_question_helper(save_survey_type)
  multi_choice_question_helper(save_survey_type)
  check_box_question_helper(save_survey_type)
  dropdown_question_helper(save_survey_type)
  scale_question_helper(save_survey_type)
  multi_choice_grid_question_helper(save_survey_type)
  check_box_grid_question(save_survey_type)
  date_question_helper(save_survey_type)
  time_qiestion_helper(save_survey_type)
  paragraph_question_helper(save_survey_type)
  picture_options_question(save_survey_type)
  picture_check_box_question(save_survey_type)
end

def survey_validate_blanks_on_share_or_draft
  scenario "users should get a validation error when they share survey" do
    populate_question_helper("2")
    fill_in("Type Your Question...", with: "")
    find("#survey-share-btn").click
    expect(page).to have_content("Question 1 cannot be empty.")
    expect(page).
      to have_content("Question 1 must contain at least two (2) options.")
    add_section
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
  end
end

private

def question_type_helper(save_survey_type)
  save_survey if save_survey_type == "published"
  save_survey if save_survey_type == "draft"
end

def multi_choice_question_helper(save_survey_type)
  scenario "users can create a survey multi-choice question type" do
    populate_question_helper("2")
    fill_in("Type Your Question...", with: "This is a multichoice question")
    fill_in("Add A Choice", with: "multichoice1")
    find(".add-choice").native.send_keys(:return)
    fill_in("Add A Choice", with: "multichoice2")
    find(".add-choice").native.send_keys(:return)
    expect(page).to have_selector(".question-wrapper")
    question_type_helper(save_survey_type)
  end
end

def check_box_question_helper(save_survey_type)
  scenario "users can create checkboxes question type" do
    populate_question_helper("3")
    fill_question_with("checkbox")
    add_choice
    expect(page).to have_selector(".question-wrapper")
    question_type_helper(save_survey_type)
  end
end

def dropdown_question_helper(save_survey_type)
  scenario "users can create dropdown question type" do
    populate_question_helper("4")
    fill_question_with("dropdown")
    add_choice
    expect(page).to have_selector(".question-wrapper")
    question_type_helper(save_survey_type)
  end
end

def scale_question_helper(save_survey_type)
  scenario "users can create scale question type" do
    populate_question_helper("5")
    fill_question_with("scale")
    find(".mdl-slider").set(6).click
    expect(page).to have_selector("li", count: 5)
    question_type_helper(save_survey_type)
  end
end

def multi_choice_grid_question_helper(save_survey_type)
  scenario "users can create multi-choice grid question type" do
    populate_question_helper("6")
    fill_question_with("multi-choice-grid")
    add_row_and_column
    expect(page).to have_selector(".question-wrapper")
    question_type_helper(save_survey_type)
  end
end

def check_box_grid_question(save_survey_type)
  scenario "users can create check-box grid question type" do
    populate_question_helper("7")
    fill_question_with("checkbox-grid")
    add_row_and_column
    expect(page).to have_selector(".question-wrapper")
    question_type_helper(save_survey_type)
  end
end

def date_question_helper(save_survey_type)
  scenario "users can create date question type" do
    populate_question_helper("8")
    fill_question_with("date")
    expect(page).to have_selector(".select-date")
    question_type_helper(save_survey_type)
  end
end

def time_qiestion_helper(save_survey_type)
  scenario "users can create time question type" do
    populate_question_helper("9")
    fill_question_with("time")
    expect(page).to have_selector(".main-display")
    question_type_helper(save_survey_type)
  end
end

def paragraph_question_helper(save_survey_type)
  scenario "users can create paragraph question type" do
    populate_question_helper("10")
    fill_question_with("paragraph")
    expect(page).to have_selector("#text-box")
    question_type_helper(save_survey_type)
  end
end

def picture_options_question(save_survey_type)
  scenario "users can create picture options question type" do
    initialize_picture_question("options", "11")
    expect(page).to have_selector(".option-image-list-item")
    save_file("fullsizeoutput_3b copy")
    question_type_helper(save_survey_type)
  end
end

def picture_check_box_question(save_survey_type)
  scenario "users can create picture checkbox question type" do
    initialize_picture_question("checkbox", "12")
    expect(page).to have_selector(".checkbox-image-list-item")
    save_file("fullsizeoutput_3b copy")
    question_type_helper(save_survey_type)
  end
end

private

def initialize_picture_question(question_type, question_id)
  populate_question_helper(question_id)
  fill_question_with(question_type)
  upload_output_file("fullsizeoutput_3b copy.jpeg", "add-file-question-0")
  upload_output_file("fullsizeoutput_3b copy.jpeg", "add-file-question-0")
end

def expect_create_survey
  expect(page).to have_content("Create a Survey")
end

def expect_form
  expect(page).to have_content("Survey Preview")
end

def expect_section_1
  expect(page).to have_content("SECTION 1")
end

def expect_add_suevey_button
  expect(page).to have_selector("#add-survey-description-btn")
end

def expect_add_question_button
  expect(page).to have_selector("#add-question-btn-0")
end

def expect_add_section_button
  expect(page).to have_selector("#add-section-btn-0")
end

def expect_share_button
  expect(page).to have_selector("#survey-share-btn")
end
