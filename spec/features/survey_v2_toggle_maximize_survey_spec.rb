require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper"

describe "Survey 2.0 setup page" do
  before :each do
    stub_admin_data_success
    stub_admin
    stub_current_session
    select_program
    visit "/surveys-v2/setup"
  end

  feature "Maximize and toggle survey builder page" do
    scenario "admin should  maximize and minimize survey builder page" do
      find("#maximize").click
      expect(page).to have_content("Create a Survey")
      expect(page).to have_content("Survey Preview")
      expect(page).to have_selector("#minimize")
      find("#minimize").click
      expect(page).to have_selector("#maximize")
      expect(page).to have_content("Create a Survey")
      expect(page).to have_content("Survey Preview")
    end

    scenario "admin should  toggle and untoggle the preview pane" do
      find("#toggleSurvey").click
      expect(page).to have_content("Create a Survey")
      expect(page).to have_selector("#untoggle")
      find("#untoggle").click
      expect(page).to have_selector("#toggleSurvey")
      expect(page).to have_content("Create a Survey")
      expect(page).to have_content("Survey Preview")
    end

    scenario "admin should toggle, maximize and minimize survey builder page" do
      find("#toggleSurvey").click
      expect(page).to have_content("Create a Survey")
      expect(page).to have_selector("#untoggle")
      find("#maximize").click
      expect(page).to have_content("Create a Survey")
      expect(page).to have_selector("#minimize")
      find("#minimize").click
      expect(page).to have_selector("#maximize")
      expect(page).to have_content("Create a Survey")
    end

    scenario "admin should maximize, toggle and untoggle preview pane" do
      find("#maximize").click
      expect(page).to have_content("Create a Survey")
      expect(page).to have_content("Survey Preview")
      expect(page).to have_selector("#minimize")
      find("#toggleSurvey").click
      expect(page).to have_content("Create a Survey")
      expect(page).to have_selector("#untoggle")
      find("#untoggle").click
      expect(page).to have_selector("#toggleSurvey")
      expect(page).to have_content("Create a Survey")
      expect(page).to have_content("Survey Preview")
    end
  end
end
