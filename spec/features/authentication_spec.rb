require "rails_helper"
require "spec_helper"

describe "Authentication test" do
  before(:all) do
    @bootcamper = create :bootcamper_with_learner_program
  end

  feature "login page" do
    scenario "contains the title of the application" do
      visit("/login")
      expect(page).to have_content("Welcome to VOF")
    end

    scenario "contains login with and password form" do
      visit("/login")
      fill_in "learners_email", with: "kiran@gmail.com"
      fill_in "learners_password", with: "Kiran.6565"
      expect(find_field("learners_email").value).to eq "kiran@gmail.com"
      expect(find_field("learners_password").value).to eq "Kiran.6565"
    end

    scenario "login with invalid email" do
      visit("/login")
      fill_in "learners_email", with: "kirangmail.com"
      fill_in "learners_password", with: "Kiran.6565"
      find("#login-learner").click
      expect(page).to have_content "Please enter a valid email address."
    end

    scenario "login with blank input fields" do
      visit("/login")
      fill_in "learners_email", with: ""
      fill_in "learners_password", with: ""
      find("#login-learner").click
      expect(page).to have_content "This field is required"
    end
  end

  xfeature "user login" do
    scenario "users should not visit the dashboard without logging in" do
      visit("/")
      expect(page).to have_content("Login to view dashboard")
    end

    xscenario "users should visit the dashboard" do
      visit("/login")
      stub_andelan
      stub_current_session
      visit("/")
      expect(page).to have_content("Home")
      clear_session
    end

    scenario "Redirect non-registered learners to the login page" do
      visit("/login")
      stub_non_andelan
      visit("/")
      expect(page).to have_current_path(login_path)
    end

    scenario "Redirect registered learners to the learners page" do
      visit("/login")
      stub_non_andelan_bootcamper @bootcamper
      stub_current_session_bootcamper @bootcamper
      visit("/")
      expect(page).to have_current_path(learner_path)
    end

    scenario "Restrict learners' access to learner's page" do
      visit("/login")
      stub_non_andelan_bootcamper @bootcamper
      stub_current_session_bootcamper @bootcamper
      visit("/content_management")
      expect(page).to have_current_path(learner_path)
    end
  end

  xfeature "user logout" do
    scenario "users should be able to logout" do
      stub_andelan
      stub_current_session
      visit("/")
      click_link("Duyile Oluwatomi")
      click_link("Logout")
      expect(page).to have_current_path(login_path)
      clear_session
    end
  end
end
