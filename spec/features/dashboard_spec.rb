require "rails_helper"
require "spec_helper"
require_relative "../support/helpers/dashboard_page.rb"

describe "Dashboard" do
  before do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
  end

  feature "displays charts for cycle and center metrics" do
    scenario "user should see seven chart panels" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      find("a#cycle-metrics-tab").click
      expect(page).to have_content("Performance Quality Over Time")
      expect(page).to have_content("Output Quality Over Time")
      expect(page).to have_content("Program Outcome Metrics")
    end
  end

  feature "displays program metrics charts" do
    scenario "user should see pie charts and bar charts" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      chart_panel("a#program-metrics-tab",
                  ["Historical Center & Gender Distribution",
                   "LFA to Learner Ratio",
                   "Average Perceived Readiness in Bootcamp across Centers",
                   "Learners Dispersion", "Program Outcome Metrics"])
    end

    scenario "user hovers over tooltip" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      sleep 1
      find("#phase-one-program-metrics-icon").hover
      expect(page).to have_content(
        "Historical numbers and percentages of learner status at the end of" \
        " week 1"
      )
    end
  end

  feature "displays tooltip for learner's dispersion" do
    scenario "user should see tooltip on hover of info icon" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      sleep 1
      find_by_id("program-metrics-tab").click
      find_by_id("learners-dispersion-icon").hover
      expect(page).to have_text("Historical numbers and percentages" \
        " of learners by centre")
    end
  end

  feature "date field" do
    scenario "users should be able to select dates" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      page.execute_script("$('input.select-start-date').val('2018-04-10')")
      page.execute_script("$('input.select_end_date').val('2018-04-30')")
      expect(page).to have_content("Start Date")
    end
  end

  feature "displays tooltip for lfa to learner ratio" do
    scenario "user should see tooltip on hover of tooltip icon" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      find_by_id("program-metrics-tab").click
      find_by_id("lfa-to-learner-ratio-icon").hover
      expect(page).to have_text("Historical LFA to Learner ratio")
    end
  end

  feature "displays tooltip for gender distribution" do
    scenario "user should see tooltip on hover of info icon" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      sleep 1
      find_by_id("program-metrics-tab").click
      page.find("a[href='#program-metrics-panel']").click
      find_by_id("gender-distribution-program-metrics-icon").hover
      expect(page).to have_text("Historical numbers and percentages" \
      " of learners by centre and gender")
    end
  end

  feature "displays tooltip for average perceived readiness across centers" do
    scenario "user should see tooltip on hover of info icon" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      sleep 1
      find_by_id("program-metrics-tab").click
      find_by_id("average_perceived_readiness-program-metrics-icon").hover
      expect(page).to have_text("Historical average perceived " \
        "readiness in bootcamp by centre.")
    end
  end

  feature "displays tooltip for performance quality over time" do
    scenario "user should see tooltip on hover of info icon" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      find_by_id("cycle-metrics-tab").click
      find_by_id("performance-quality-icon").hover
      expect(page).to have_text("Average holistic performance and dev " \
      "framework quality for accepted learners by cycle")
    end
  end

  feature "Download Anayltics Data" do
    scenario "user should see the export button" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      button = find(".export-container")
      expect(button.text).to eq("Export")
    end
  end
end
