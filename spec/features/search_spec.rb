require "rails_helper"
require "spec_helper"
require "helpers/search_helper_spec"

RSpec.feature "Search", type: :feature do
  include SearchHelpers
  before do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
  end

  feature "Search using different modifiers" do
    scenario "user should be redirected to curriculum page" do
      initialize_search(".modifiers-dropdown ul > :first-child", "self")
      expect(page).to have_content(/Showing \d* results? for \"self\"/)
      expect(current_path).to have_content "/curriculum"
    end

    scenario "user should be redirected to learners page" do
      initialize_search(".modifiers-dropdown ul > :nth-child(2)", "stephen")
      expect(page).to have_content("Showing results for \"stephen\" ")
      expect(current_path).to have_content "/learners"
    end

    scenario "user should be redirected to support page" do
      initialize_search(".modifiers-dropdown ul > :nth-child(3)", "dlc")
      expect(page).to have_content("Showing results for \"dlc\"")
      expect(current_path).to have_content "/support"
    end

    scenario "user should see an error if search modifier is not provided" do
      find(".search-box").click
      fill_in("search", with: "hello")
      find(".search-box > input").native.send_keys(:return)
      error = find(".modifier-error")
      expect(error.text).to eq("Please select a modifier")
    end

    scenario "user should see an error if search query is not provided" do
      find(".search-box").click
      find(".modifiers-dropdown ul > :first-child").click
      find(".search-box > input").native.send_keys(:return)
      error = find(".modifier-error")
      expect(error.text).to eq("Please enter a search term")
    end
  end
end
