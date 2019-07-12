require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper"

describe "Survey 2.0 archive published survey" do
  before :each do
    stub_admin
    stub_current_session_admin
    select_program
    visit "/surveys-v2/"
  end

  before :all do
    @survey = create(:new_survey, :published)
    create(:survey_section, new_survey_id: @survey.id)
  end

  feature "Archiving and unarchiving published surveys" do
    scenario "Admin should archive a published survey" do
      find("[data-survey_id='#{@survey.id}'] .survey-card-body").click
      expect(page).to have_content("Accepting Responses")
      expect(page).to have_selector(".mdl-switch")
      find(".mdl-switch").click
      expect(page).to have_content("Survey successfully put on hold")
    end

    scenario "Admin should be able to publish archived surveys" do
      find("[data-survey_id='#{@survey.id}'] .survey-card-body").click
      NewSurvey.update(
        status: "archived"
      )
      find(".mdl-switch").click
      expect(page).to have_content("Successfully updated status to published")
    end
  end
end
