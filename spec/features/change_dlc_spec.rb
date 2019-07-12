require "rails_helper"
require "spec_helper"
require "helpers/responsive_helpers"

RSpec.feature "DLC programs", type: :feature do
  describe "Change DLC programs" do
    before :all do
      @program_one = Program.first || create(:program)
      @program_two = Program.all[1] || create(:program)
    end

    before do
      stub_andelan
      stub_current_session
      visit "/"
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
    end

    feature "DLC programs on mobile screens" do
      before do
        ResponsiveHelpers.resize_window_to_mobile
        # find("a#skip-tour-btn").click
      end

      after :all do
        ResponsiveHelpers.resize_window_to_default
      end

      scenario "user can click create new program" do
        find(".icon-bars").click
        find("ul li.mobile-add-program a.add-program-btn").click
        expect(page).to have_content("Add Program")
      end

      scenario "user should see list of available programs" do
        find(".icon-bars").click
        sleep 1
        find("ul li.mobile-dlc-options .mobile-dlc").click
        expect(page).to have_content(@program_one.name)
      end

      scenario "user can change dlc on large screens" do
        find(".icon-bars").click
        find("ul li.mobile-dlc-options .mobile-dlc").click
        expect(page).to have_selector(:link_or_button, @program_one.name)
      end

      scenario "user can change dlc" do
        find(".icon-bars").click
        find("ul li.mobile-dlc-options .mobile-dlc").click
        expect(page).to have_link(href: "/learners?program_id=1")
      end
    end

    feature "DLC programs" do
      before do
        page.driver.browser.manage.window.resize_to(1700, 1200)
        # find("a#skip-tour-btn").click
      end
      scenario "user should see name of current DLC program" do
        expect(page).to have_selector(:link_or_button, @program_one.name)
      end

      scenario "user can click create new program" do
        find("a.program-select").click
        find("ul.dropdown-content li a.add-program-btn").click
        expect(page).to have_content("Add Program")
      end

      scenario "user should see list of available programs" do
        find("a.program-select").click
        expect(page).to have_content(@program_one.name)
      end

      scenario "user can change dlc" do
        find("a.program-select").click
        find("ul.dropdown-content li a.dropdown-link").click
        expect(page).to have_selector(:link_or_button, @program_one.name)
      end
    end
  end
end
