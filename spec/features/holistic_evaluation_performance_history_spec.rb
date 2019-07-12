require "rails_helper"
require "spec_helper"
require "helpers/learners_page_helper_spec"

describe "Holistic performance scores history modal test" do
  before :all do
    program = Program.first

    create_list(:learner_program, 2, program_id: program.id)
    @first_bootcamper =
      create(:learner_program, program_id: 1).bootcamper
    @second_bootcamper =
      create(:learner_program, program_id: 1).bootcamper

    @second_camper_name = @second_bootcamper.name
    @holistic_evaluation = create(
      :holistic_evaluation,
      learner_program_id: @second_bootcamper.learner_programs.first.id
    )
  end

  before do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    click_on "Learners"
  end

  feature "view holistic performance history" do
    scenario "user should see 'No data to display'" do
      camper_name = @first_bootcamper.name
      click_link(camper_name)
      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      find(".score-history-btn").click
      history_modal = find(".holistic-evaluation-history")

      expect(history_modal).to have_content("No data to show :(")
    end

    scenario "user should see holistic evaluations history" do
      click_link(@second_camper_name)

      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      find(".score-history-btn").click
      find(".accordion-section-title").click
      criteria = first("div.holistic-criteria-wrapper")

      expect(criteria).to have_content(@holistic_evaluation.criterium.name)
    end

    scenario "user should input scores within range of -2 and 2" do
      click_link(@second_camper_name)

      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      find(".score-history-btn").click
      find(".accordion-section-title").click
      sleep 1
      find("span.edit-holistic-evaluation-btn").click
      input_score = find("select[name=scores]", visible: false).value

      expect(input_score).to satisfy do |value|
        (value >= "-2") && (value <= "2")
      end
    end

    scenario "user should be able to expand truncated comments" do
      click_link(@second_camper_name)

      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      find(".score-history-btn").click
      find(".accordion-section-title").click

      criteria = first("div.holistic-criteria-wrapper")
      show_more = criteria.find(".show-more-link").click

      expect(show_more).to have_content("Show less")
    end
  end

  feature "export learner's holistic performance data" do
    scenario "admin should see export button" do
      click_link(@second_camper_name)

      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      find(".score-history-btn").click
      button = find("a.export-btn.scores-history-export-btn")
      expect(button.text).to eq("Export")
    end

    xscenario "non-admin should not see export button" do
      stub_andelan_non_admin
      click_link(@second_camper_name)

      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      find(".score-history-btn").click
      expect(page).to have_no_selector("a.export-btn.scores-history-export-btn")
    end

    scenario "export holistic evaluation csv" do
      click_link(@second_camper_name)

      find("a.evaluation-select").click
      find(".holistic-evaluation-btn").click
      find(".score-history-btn").click
      find("a.export-btn.scores-history-export-btn").click
      expect(DownloadHelpers.
        download_content).to include "Holistic Evaluation Performance"
    end
  end
end
