require "rails_helper"
require "spec_helper"
require "helpers/pitch_helper.rb"

describe "Pitch setup page" do
  include CreatePitchHelper
  before :all do
    create_seed_data
  end

  before(:each) do
    stub_admin
    stub_current_session_admin
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link", text: @program.name).click
    find("img.proceed-btn").click
    visit("/pitch")
  end

  after :all do
    clear_seed_data
  end

  feature "Admin View ongoing Pitches" do
    scenario "expect to see Add a new Pitch when there is no pitch" do
      expect(page).to have_content("Add a new Pitch")
    end

    scenario "expect to see all ongoing pitches when there are pitches" do
      visit("/pitch")
      expect(page).to have_css(".add-new-pitch-card")
      expect(page).to have_css(".pitch-card")
    end
  end

  feature "Admin can edit a Pitch" do
    scenario "expect to redirect to Edit Pitch Page" do
      first(".pitch-card .more-icon").hover
      find(".dropdown-item .edit").click
      expect(page).to have_content("Update Pitch")
    end

    scenario "expect to successfully edit Pitch" do
      first(".pitch-card .more-icon").hover
      find(".dropdown-item .edit").click
      find("#next-btn").click
      sleep 1
      fill_in("invite-panelist", with: "efe.love@andela.com")
      find(".add-invitee-icon ").click
      find("#next-btn").click
      find("a.ui-state-default", match: :first).click
      find(".update-next").click
      sleep 1
      expect(current_path).to eq("/pitch/#{@pitch.id}")
    end
  end

  feature "Delete a pitch" do
    scenario "admin can delete a pitch" do
      first(".pitch-card .more-icon").hover
      find(".dropdown-item.delete").click
      expect(page).to have_content("Confirm Delete")
      find("#confirm-delete-pitch").click
      expect(page).to have_css(".pitch-card", count: 1)
    end
  end

  feature "Admin can click on pagination button" do
    scenario "Admin should be able to see a pagination control" do
      create_multiple_pitches(16)
      expect(page).to have_css(".pagination-control")
      expect(page).to have_css(".main-pages")
      expect(page).to have_css(".page.active-page")
    end

    scenario "Admin should be able to navigate between pages" do
      next_button = find(".next-arrow")
      previous_button = find(".prev-arrow")
      sleep 1
      next_button.click
      previous_button.click

      expect(page).to have_css(".prev-next")
    end
  end

  feature "LFA/Observer View" do
    before(:each) do
      clear_session
      stub_andelan_non_admin
      stub_current_session_non_admin
      visit("/pitch")
    end

    scenario "it redirects to index route if not Admin" do
      sleep 1
      expect(current_path).to eq("/")
    end
  end
end
