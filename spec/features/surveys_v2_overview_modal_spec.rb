require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper"

describe "Survey V2 Overview Modal" do
  before do
    stub_admin_two
    stub_current_session_admin_two
    select_program
  end

  before :all do
    survey_creator = "daniel@andela.com"
    @survey = create(:new_survey, :published, survey_creator: survey_creator)
    @section = create(:survey_section, new_survey_id: @survey.id)
    paragraph = create(:survey_paragraph_question)
    create(:survey_question, survey_section_id: @section.id,
                             questionable_id: paragraph.id,
                             questionable_type: "SurveyParagraphQuestion")
    scale = create(:survey_scale_question)
    create(:survey_question, survey_section_id: @section.id,
                             questionable_id: scale.id,
                             questionable_type: "SurveyScaleQuestion")
    date = create(:survey_date_question)
    create(:survey_question, survey_section_id: @section.id,
                             questionable_id: date.id,
                             questionable_type: "SurveyDateQuestion")
    time = create(:survey_time_question)
    create(:survey_question, survey_section_id: @section.id,
                             questionable_id: time.id,
                             questionable_type: "SurveyTimeQuestion")
  end

  feature "Admin can" do
    scenario "see the created survey" do
      find("[data-survey_id='#{@survey.id}']")
      expect(page).to have_content(@survey.title.capitalize)
    end

    scenario "see the overview modal" do
      find("[data-survey_id='#{@survey.id}'] .survey-card-body").click
      expect(page).to have_css(".preview-active")
    end

    scenario "see the paragraph question" do
      find("[data-survey_id='#{@survey.id}'] .survey-card-body").click
      expect(page).to have_css(".paragraph-wrapper")
    end

    scenario "see the scale question" do
      find("[data-survey_id='#{@survey.id}'] .survey-card-body").click
      expect(page).to have_css(".scale")
    end

    scenario "see the date question" do
      find("[data-survey_id='#{@survey.id}'] .survey-card-body").click
      expect(page).to have_css(".cal")
    end

    scenario "see the scale question" do
      find("[data-survey_id='#{@survey.id}'] .survey-card-body").click
      expect(page).to have_css(".main-display")
    end
  end
end
