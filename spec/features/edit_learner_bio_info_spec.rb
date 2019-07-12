require "rails_helper"
require "spec_helper"
require "helpers/learner_bio_helper"

describe "Edit learner bio information modal test" do
  include LearnerBioHelper

  before :all do
    @learner = create(:bootcamper)
    set_up
  end

  after :all do
    tear_down
  end

  before :each do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    click_on "Learners"
  end

  feature "edit learner bio information" do
    scenario "user should see edit learner modal" do
      learner_name = @bootcamper.first_name + " " + @bootcamper.last_name
      sleep 1
      find_link(learner_name).click
      find("div.profile span.edit-learner-icon").click
      edit_modal = find(".edit-learner-bio-info-modal")
      expect(edit_modal).to have_content(learner_name)
    end

    scenario "user should see message on successful update" do
      learner_name = @bootcamper.first_name + " " + @bootcamper.last_name
      sleep 1
      find_link(learner_name).click
      find("div.profile span.edit-learner-icon").click
      expect(page).to have_no_content(@new_email)
      expect(page).to have_no_content(@new_center.name)
      find("input.learner-email").set(@new_email)
      sleep 2
      find(".learner-gender span#select-dropdown-button").click
      find(".ui-menu-item", text: "Male").click
      find(".save-learner-info").click
      expect(page).to have_content(@new_email)
      response_message = "Learner Information updated successfully"
      expect(page).to have_content(response_message)
    end

    scenario "user should see message on successful update" do
      learner_name = @bootcamper.first_name + " " + @bootcamper.last_name
      sleep 1
      find_link(learner_name).click
      find("div.profile span.edit-learner-icon").click
      find("input.learner-email").set(@learner.email)
      find(".save-learner-info").click
      expect(page).to have_content("email has already been taken")
    end
  end
end
