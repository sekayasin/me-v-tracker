require "rails_helper"
require "spec_helper"
require "helpers/program_helpers"

RSpec.feature "Program", type: :feature do
  include ProgramHelpers

  before :all do
    @program = create_list(:program, 100)
  end

  before do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    find("#programs-link").click
  end

  feature "Pagination on view all programs" do
    scenario "Admin should be able to see a pagination control" do
      expect(page).to have_css(".pagination-control")
      expect(page).to have_css(".main-pages")
      expect(page).to have_css(".page.active-page")
    end

    scenario "Admin should be able to navigate between pages" do
      next_button = find(".next")
      previous_button = find(".prev")
      sleep 1
      next_button.click
      next_button.click
      next_button.click
      next_button.click
      previous_button.click
      previous_button.click
      previous_button.click
      previous_button.click

      expect(page).to have_css(".prev-next.grey-out")
    end
  end
end
