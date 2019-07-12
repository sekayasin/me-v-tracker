require "rails_helper"
require "spec_helper"

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

  feature "edit frameworks modal" do
    scenario "admin should not be able to submit form with empty fields " do
      visit("/curriculum")
      find(".learning-outcomes-panel").click
      sleep 1
      first(".edit-icon").click
      within(".modal") do
        fill_in("assessment[name]", with: "")
        fill_in("assessment[expectation]", with: "")
        fill_in("assessment[description]", with: "")
        fill_in("assessment[context]", with: "")
        fill_in("assessment[metrics_attributes][0][description]", with: "")
        fill_in("assessment[metrics_attributes][1][description]", with: "")
        find("input#confirm-submission").click
      end

      expect(page).to have_content("This field is required.", count: 6)
    end

    scenario "admin should successfully edit learning outcome" do
      new_name = "New name"
      new_expectation = "New expectation"
      new_context = "New context"

      visit("/curriculum")
      find(".learning-outcomes-panel").click
      sleep 1
      first(".edit-icon").click
      sleep 1
      within(".modal") do
        fill_in("assessment[name]", with: new_name)
        fill_in("assessment[expectation]", with: new_expectation)
        fill_in("assessment[context]", with: new_context)
        find("input#confirm-submission").click
      end

      expect(page).to have_content("Learning outcome updated successfully")
      expect(page).to have_content(new_name)
      expect(page).to have_content(new_expectation)
    end
  end
end
