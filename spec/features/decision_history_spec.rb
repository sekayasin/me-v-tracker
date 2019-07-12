require "rails_helper"
require "spec_helper"
require "helpers/decision_history_helpers"

describe "Decision history modal test" do
  include DecisionHistoryHelpers

  before :all do
    set_up
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

  feature "view decision history" do
    scenario "user should see 'No data to display'" do
      camper_one_first_name = @first_bootcamper.first_name
      camper_one_second_name = @first_bootcamper.last_name
      first_camper_name = "#{camper_one_first_name} #{camper_one_second_name}"

      click_link(first_camper_name)
      find("a#decision-history-view").click
      history_modal = find(".decision-history-modal")

      expect(history_modal).to have_content("No data to show :(")
    end

    scenario "user should see decision history" do
      camper_two_first_name = @second_bootcamper.first_name
      camper_two_second_name = @second_bootcamper.last_name
      second_camper_name = "#{camper_two_first_name} #{camper_two_second_name}"

      click_link(second_camper_name)
      find("a.view-decision-history").click
      first(".accordion-section-title").click
      sleep 1

      history_modal = find(".decision-history-modal")
      decision_details = history_modal.all(".decision-detail-div")

      expect(decision_details.length).to eq 4
      expect(decision_details[0]).to have_content("LFA")
      expect(decision_details[3]).to have_content(@decision.comment)
    end
  end
end
