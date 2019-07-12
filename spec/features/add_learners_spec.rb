require "rails_helper"
require "spec_helper"
require "helpers/add_facilitator_helper.rb"
require_relative "../support/add_learner_feature_helper.rb"

describe "Add learners" do
  include AddFacilitatorHelper
  before :each do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    click_on "Learners"
  end
  before :all do
    create_seed_data
  end

  feature "add learner button" do
    scenario "admin users should see an add-learner-button" do
      expect(page).to have_xpath("//a", id: "add-learner")
    end
  end

  feature "add learner modal form" do
    scenario "admin users should see an add learner modal form" do
      find("a#add-learner").click
      expect(page).to have_xpath("//div", id: "add-learner-modal")
    end

    scenario "users should fill and submit the form successfully" do
      upload_learner_helper("samplelearner.xlsx")
      expect(page).to have_xpath("//h4", text: "Upload Successful", count: 1)
    end

    scenario "admin users should see existing users on upload success" do
      upload_learner_helper("samplelearner.xlsx")
      find("#confirm-upload-learner").click
      expect(page).to have_content(
        "NB: The following learners have already been added"
      )
    end
  end

  feature "LFA notification" do
    scenario "week one LFA receives new learner notification" do
      find("a.notifications-trigger").click
      expect(page).to have_content("You have been assigned a new Learner")
    end
  end
end
