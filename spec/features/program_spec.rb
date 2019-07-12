require "rails_helper"
require "spec_helper"
require "helpers/program_helpers"

RSpec.feature "Program", type: :feature do
  include ProgramHelpers

  before :all do
    create_finalised_program
  end

  before :each do
    stub_andelan
    stub_current_session
    stub_admin_data_success
    visit("/")
    find("a.dropdown-input").click
    first("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    click_on "Learners"
  end

  after :all do
    program_ids = Program.where(name: "Gryffindor").
                  or(Program.where(name: "Thesaurus")).
                  or(Program.where(name: "Cloned Program")).
                  pluck(:id)
    program_ids.each do |program_id|
      ProgramsPhase.where(program_id: program_id).delete_all
      Program.where(id: program_id).delete_all
    end
    Program.where(name: @program.name).delete_all
    Notification.delete_all
    NotificationsMessage.delete_all
  end

  feature "Admin Create new program" do
    scenario "user should be able to create a new program" do
      sleep 1
      find(".icon-container").click
      find(".add-new-program").click
      fill_and_submit_form("Gryffindor", "theoden")

      expect(page).to have_content("Program Successfully Created")
    end

    # TODO: Fix this flaky test
    xscenario "admin can see newly created program on programs page" do
      visit("/programs")
      find(".icon-container").click
      find(".add-new-program").click
      fill_and_submit_form("Thesaurus", "Bianconeri")

      expect(page).to have_content("Thesaurus")
    end

    scenario "admins should get notification after program is created" do
      find("a.notifications-trigger").click
      expect(page).to have_content("A new program has been created: Gryffindor")
    end

    scenario "user shouldn't be able to submit blank forms" do
      find(".icon-container").click
      find(".add-new-program").click
      click_button "Save"

      expect(page).to have_content("Program Name is required")
      expect(page).to have_content("Program Description is required")
      expect(page).to have_content("Program Phase is required")
    end

    scenario "user shouldn't create program with already existing name" do
      find(".icon-container").click
      find(".add-new-program").click
      fill_and_submit_form("Gryffindor", "matterhorn")

      expect(page).to have_content("Name has already been taken")
    end

    scenario "admin redirected attempting to edit a finalized program" do
      visit("/programs/1/edit")
      expect(page.current_path).to eq "/programs"
      expect(page).to have_content "All Programs"
    end
  end

  feature "Non-admin programs view" do
    before do
      stub_andelan_non_admin
      visit("/")
      find("a.dropdown-input").click
      first("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
    end

    scenario "non-admin should get redirected from the programs page" do
      visit("/programs")
      expect(page.current_path).to eq "/"
      expect(page).to have_content("Thanks!\nPlease select which\nAndela")
    end
  end

  feature "View all programs" do
    scenario "User should be able view all programs" do
      find("#programs-link").click

      expect(page).to have_content("Gryffindor")
    end
  end

  feature "View finalised programs details" do
    scenario "User should see the view icon on the finalised programs row" do
      find("#programs-link").click

      expect(page).to have_selector("#view-icon-#{@program.id}")
    end

    scenario "User should view the program details modal" do
      find("#programs-link").click
      find("#view-icon-#{@program.id}").click

      expect(page).to have_selector(".header-text")
      expect(page).to have_content(@program.name)
    end
  end
end
