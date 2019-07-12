require "rails_helper"
require "spec_helper"
require "helpers/pitch_helper.rb"

describe "Pitch setup page" do
  include CreatePitchHelper
  before :all do
    create_seed_data
  end

  after :all do
    clear_seed_data
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

  feature "Create a Pitch" do
    scenario "Fill in the required details" do
      expect(page).to have_css(".pitch-card")
    end
  end

  feature "pitch past date" do
    scenario "View Pitch with past date" do
      expect(page).to have_content("Past")
    end
  end
end
