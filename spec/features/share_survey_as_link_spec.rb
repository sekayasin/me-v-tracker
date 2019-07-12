require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper.rb"

describe "Survey 2.0 index page" do
  before(:each) do
    stub_admin
    stub_current_session
    select_program
  end
  before :all do
    @survey = create(:new_survey, :published)
    create(:survey_section, new_survey_id: @survey.id)
  end

  feature "Admin can share a survey as a link" do
    scenario "expect to share survey as a link" do
      first(".survey-card .more-icon").hover
      first(".survey-card #edit-form").click
      visit("/surveys-v2/#{@survey.id}/edit")
      expect(page).to have_content("Share")
      find("#survey-share-btn").click
      expect(page).to have_content("Link")
      find("#sharelink-icon").click
      expect(page).to have_content("Collaborator's link")
      expect(page).to have_content("Learner's link")
      expect(page).to have_content("Copy Link")
      find(".copy-survey-link").click
      expect(page).to have_content("Successfully copied")
      find(".copy-learner-link").click
      expect(page).to have_content("Successfully copied")
    end
  end
end
