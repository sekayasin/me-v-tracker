require "rails_helper"
require "spec_helper"

describe "CycleCentreMetrics" do
  before do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    visit("/analytics")
  end

  feature "displays tooltip for the output quality chart" do
    scenario "user should see a tooltip on hovering" do
      sleep 1
      # find("a#skip-tour-btn").click
      find_by_id("cycle-metrics-tab").click
      find_by_id("output-quality-icon").hover
      expect(page).to have_text(
        "Average output expectations ratings for accepted learners by cycle"
      )
    end
  end

  feature "displays gender distribution chart tooltip" do
    scenario "user should see tooltip on hover" do
      sleep 1
      # find("a#skip-tour-btn").click
      find_by_id("cycle-metrics-tab").click
      find_by_id("gender-distribution-icon").hover
      expect(page).to have_text(
        "This is the percentage of Male to Female learners."
      )
    end
  end

  feature "displays gender distribution chart tooltip" do
    scenario "user should see tooltip on hover" do
      sleep 1
      # find("a#skip-tour-btn").click
      find_by_id("cycle-metrics-tab").click
      find_by_id("learner-quantity-icon").hover
      expect(page).to have_text(
        "Total number of learners accepted"
      )
    end
  end

  feature "Program Outcome Metrics" do
    scenario "user should see tooltip on hover" do
      sleep 1
      # find("a#skip-tour-btn").click
      find_by_id("cycle-metrics-tab").click
      find_by_id("program-outcome-week-two-icon").hover
      expect(page).to have_text(
        "Historical numbers and percentages of learner status at the end"
      )
    end
  end

  feature "lfa to learner ratio" do
    scenario "user should see tooltip on hover" do
      sleep 1
      # find("a#skip-tour-btn").click
      find_by_id("cycle-metrics-tab").click
      find_by_id("lfa-learner-ratio-icon").hover
      expect(page).to have_text(
        "Historical LFA to Learner ratio (number of LFAs to number of Learners)"
      )
    end
  end
end
