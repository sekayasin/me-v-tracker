require "rails_helper"
require "spec_helper"
require "helpers/pitch_helper.rb"

describe "Panelist Pitch Dashboard" do
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
    create_new_pitch
  end

  after :all do
    clear_seed_data
  end

  feature "Panelist View Invited Pitches" do
    before(:each) do
      clear_session
      stub_andelan_panelist
      stub_current_session_panelist
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link", text: @program.name).click
      find("img.proceed-btn").click
      visit("/pitch")
    end

    scenario "panelist should see all pitches he/she is invited to" do
      expect(page).to have_css(".pitch-card")
      expect(page).to have_css(".btn-card")
    end
  end
end
