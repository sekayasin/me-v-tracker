require "rails_helper"
require "spec_helper"

describe "Frameworks tab test" do
  before(:each) do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    visit("/curriculum")
  end

  feature "frameworks table" do
    scenario "user should see a table displaying frameworks" do
      find(".framework-tab").click
      expect(page).to have_content("Framework")
      expect(page).to have_content("Description")
    end
  end

  feature "edit frameworks modal" do
    scenario "admin should not be able to submit an empty description" do
      find(".framework-tab").click
      first(".edit-framework-icon").click
      within(".edit-framework-modal") do
        fill_in("framework_description_input", with: "")
        find(".edit-framework-save").click
      end

      expect(page).to have_content("Framework description is required!")
    end

    scenario "admin should succcessfully edit a framework description" do
      new_description = "Edited this framework description"
      find(".framework-tab").click
      first(".edit-framework-icon").click
      within(".edit-framework-modal") do
        fill_in("framework_description_input", with: new_description)
        find(".edit-framework-save").click
      end

      expect(page).to have_content("Framework updated successfully")
      expect(page).to have_content(new_description)
    end
  end
end
