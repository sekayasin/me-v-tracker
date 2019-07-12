require "rails_helper"
require "spec_helper"
require "helpers/learners_page_helper_spec"
require "helpers/bootcamper_data_export_helper_spec"

describe "Learners' page test" do
  feature "when bootcampers exist" do
    RSpec.configure do |c|
      c.include BootcamperDataExportHelper
    end
    before :all do
      first_db_setup
      second_db_setup
    end

    before :each do
      DownloadHelpers.clear_downloads
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("a", text: @program.name).click
      find("img.proceed-btn").click
      click_on "Learners"
      page.driver.
        execute_script("document.querySelector('.location').scrollIntoView()")
    end

    feature "visiting the Learners page" do
      scenario "displays all learner data" do
        expect(page).to have_content("Location")
        expect(page).to have_content(
          "#{@bootcamper_one.first_name} #{@bootcamper_one.last_name}"
        )
        expect(page).to have_content(
          "#{@bootcamper_two.first_name} #{@bootcamper_two.last_name}"
        )
        expect(page).to have_content(@center.name)
      end
    end

    feature "Download Learners' data as CSV" do
      scenario "admin should see the export button" do
        button = find("a.export-btn")
        expect(button.text).to eq("Export")
      end

      scenario "csv file should be downloaded when export button is clicked" do
        find("a.export-btn").click
        sleep 5
        expect(
          DownloadHelpers.downloads[0].chars.last(3).join
        ).to eq "csv"
      end

      scenario "downloaded csv file should contain valid data" do
        find("a.export-btn").click
        expect(
          DownloadHelpers.download_content
        ).to include "Greenhouse Candidate ID"
        expect(
          DownloadHelpers.download_content
        ).to include @bootcamper_one.first_name
        expect(
          DownloadHelpers.download_content
        ).to include @bootcamper_two.first_name
      end

      scenario "non-admin users cannot see the export button" do
        stub_andelan_non_admin
        stub_current_session
        expect(page).to have_no_selector("a.export-btn")
      end
    end

    feature "When a cycle has ended" do
      before :all do
        cycle_center = create(:cycle_center, end_date: Date.yesterday)
        @learner_program_three = create(
          :learner_program,
          program_id: @program.id,
          cycle_center: cycle_center
        )
      end
      def find_decision(decision)
        find(
          :css,
          "tr[data-program_id='#{@learner_program_three.program.id}']"\
          " td.#{decision} .decision-status-input", match: :first
        ).click
      end
      scenario "decision one input field should be disabled" do
        decision_one = find_decision("decision-one")
        expect(decision_one[:disabled]).to eq("true")
      end

      scenario "decision two input field should be disabled" do
        decision_two = find_decision("decision-two")
        expect(decision_two[:disabled]).to eq("true")
      end
    end
  end
end
