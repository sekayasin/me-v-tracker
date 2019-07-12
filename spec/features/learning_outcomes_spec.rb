require "rails_helper"
require "spec_helper"
require "helpers/responsive_helpers"

describe "Curriculum page test" do
  before(:each) do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
  end

  before(:all) { page.driver.browser.manage.window.resize_to(1440, 900) }
  after(:all) { ResponsiveHelpers.resize_window_to_default }

  feature "add learning outcomes" do
    scenario "admin is able to add a new learning outcome" do
      visit("/curriculum")
      sleep 1
      find(".learning-outcomes-panel").click
      find(".add-outcome").click
      find("#framework_criterium_framework_id-button").click
      sleep 1
      find("li", text: "Output Quality").click
      find("#framework_criterium_criterium_id-button").click
      find("li", text: "Quality").click
      within("#new_assessment") do
        fill_in("assessment-name-id", with: "test assessment")
        fill_in("assessment-description", with: "My description")
        fill_in("assessment-expectation", with: "My expectation")
        fill_in("context", with: "Context of my assessment")
        fill_in("N/R", with: "Didnt attempt any")
        fill_in("Below Expectations", with: "Output Below Expectations")
        fill_in("At Expectations", with: "Output Meets Expectations")
        fill_in("Exceeds Expectations", with: "Output Exceeds Expectations")
      end
      find("#confirm-submission").click
      expect(page).to have_content("Assessment Successfully created")
    end

    scenario "non admin should be able to add a new learning outcome" do
      stub_andelan_non_admin
      stub_current_session
      visit("/curriculum")
      sleep 1
      find(".learning-outcomes-panel").click
      expect(page).not_to have_content("Add Outcome")
    end
  end

  feature "edit learning outcome" do
    scenario "admin can specify an outcome to require multiple submissions" do
      visit("/curriculum")
      sleep 1
      find(".learning-outcomes-panel").click
      sleep 1
      first(".edit-icon").click
      sleep 1
      find("#requires-submission-label").click
      find("#multiple_submissions-button").click
      find(".ui-menu-item", text: "Yes").click
      find("#submission-phase-id-button").click
      all(".ui-menu-item", visible: true)[1].click
      find("#file-type-for-1-button").click
      find(".ui-menu-item", text: "File Upload Only").click
      find("#confirm-submission").click
      expect(page).to have_content("Learning outcome updated successfully")
    end
  end

  feature "delete learning outcome" do
    scenario "admin should successfully archive a learning outcome" do
      visit("/curriculum")
      sleep 1
      find(".learning-outcomes-panel").click
      sleep 1
      first(".archive-icon").click
      sleep 1
      expect(page).to have_content("This will render this learning outcome "\
      "inaccessible in areas it was previously used. Are you sure you want to "\
      "archive this learning outcome?")
      find("input#confirm-archive-outcome").click
      expect(page).to have_content(
        "Learning Outcome has been archived successfully"
      )
    end

    scenario "non admin should not be able to archive a learning outcome" do
      stub_andelan_non_admin
      stub_current_session
      visit("/curriculum")
      sleep 1
      find(".learning-outcomes-panel").click
      sleep 1
      expect(page).not_to have_selector(".archive-icon")
    end
  end

  feature "Users can filter learning outcomes by program" do
    before do
      page.driver.browser.manage.window.resize_to(1700, 1200)
    end
    scenario "users should be able to view paginated learning outcomes" do
      stub_andelan_non_admin
      stub_current_session
      visit("/curriculum")
      sleep 1
      find(".learning-outcomes-panel").click
      expect(page).to have_selector(".pagination-control")
    end

    scenario "users should be able to filter through the paginated outcomes" do
      stub_andelan_non_admin
      stub_current_session
      visit("/curriculum")
      sleep 1
      find(".learning-outcomes-panel").click
      find("#framework-filter-outcome-button").click
      first(".ui-menu-item", visible: true, text: Framework.first.name).click
      expect(page).to have_selector(".framework-data > span",
                                    text: Framework.first.name)
    end
  end
end
