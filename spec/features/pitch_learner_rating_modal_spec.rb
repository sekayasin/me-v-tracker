require "rails_helper"
require "spec_helper"
require "helpers/pitch_helper.rb"

describe "Learner Rating Modal" do
  include CreatePitchHelper
  before :all do
    create_pitch_with_ratings
  end

  after :all do
    clear_pitch_with_ratings
  end

  before(:each) do
    clear_session
    pitch_setup(stub_admin, stub_current_session_admin)
  end

  feature "Admin can" do
    scenario "see the learner rating modal" do
      page.all(".persona-card-body").last.click
      test_learner_modal_contents
      expect(page).to have_css(".learner-cumulative-decision")
      expect(page).to have_css(".cumulative-average")
    end

    scenario "see the break down of learner ratings by panelists" do
      page.all(".persona-card-body").last.click
      find(".learner-dropdown").click
      expect(page).to have_css(".view-score-breakdown")
      expect(page).to have_css(".lfa-modal-dialog")
      expect(page).to have_css(".lfa-modal-dialog-field")
      expect(page).to have_css(".group-3")
    end

    scenario "hover over panelists' initials to see their full name" do
      page.all(".persona-card-body").last.click
      find(".learner-dropdown").click
      first(".group-3-rating .oval").hover
      expect(page).to have_content("Efe Love")
    end

    scenario "see pitch summary tab" do
      find(".summary-tab").click
      expect(page).to have_css(".pitch-summary-table-body")
      expect(page).to have_css(".pitch-summary")
    end

    scenario "see a learner's rating breakdown" do
      find(".summary-tab").click
      find(".one-learner-breakdown").click
      sleep 1
      expect(page).to have_css(".ratings-container")
    end
  end

  feature "Admin can" do
    before :all do
      clear_pitch_with_ratings
      create_seed_data
    end

    after :all do
      clear_seed_data
    end

    scenario "see error message if learner has not been graded" do
      page.all(".persona-card-body").first.click
      expect(page).to have_content("Learner is yet to be graded.")
    end
  end
end
