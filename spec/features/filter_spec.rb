require "rails_helper"
require "spec_helper"
require "helpers/submissions_helper_spec"

describe "Filter learners on submissions page" do
  RSpec.configure do |c|
    c.include SubmissionsHelper
  end
  before :all do
    first_db_setup
    second_db_setup
  end

  feature "view filtered learners on submissions page" do
    before(:each) do
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/submissions")
    end
    scenario "admin should be able to view filter" do
      expect(page).to have_content("Location")
      expect(page).to have_content("Cycle")
      expect(page).to have_content("LFA 1")
      expect(page).to have_content("LFA 2")
    end

    scenario "admin should not see cycles on cycle dropdown" do
      first("#cycle-filter").click
      expect(page).to have_content("Select location to search")
      expect(page).to have_selector("#search-cycle", visible: false)
      expect(page).to have_selector("#cycles", visible: false)
    end

    scenario "admin should be select location" do
      find("#location-box").click
      sleep(2)
      find("#location-list").click
      find(".list-checkbox").click
      find_button("Apply").click
      expect(page).to have_selector("input")
      expect(page).to have_selector(".checkbox-label")
      expect(page).to have_selector("#location-list")
      expect(page).to have_content("Select All")
    end

    scenario "admin should be able filter by clicking apply button" do
      find(".filter-btn").click
      expect(page).to have_selector("#submissions-page-container")
      expect(page).to have_content("Location")
      expect(page).to have_content("Cycle")
      expect(page).to have_content("LFA 1")
      expect(page).to have_content("LFA 2")
    end
  end
end
