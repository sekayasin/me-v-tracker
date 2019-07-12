require "rails_helper"
require "spec_helper"

describe "Cycle Dropdown" do
  before do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
  end

  feature "populate cycle dropdown for selected center" do
    before :each do
      CycleCenter.delete_all
    end

    before :all do
      cycle_one = create(:cycle, cycle: 31)
      cycle_two = create(:cycle, cycle: 32)
      center = create(:center, name: "Lagos", country: "Nigeria")
      create(:target)
      cycle_center_one = create(:cycle_center, center: center,
                                               cycle: cycle_one, program_id: 1)
      cycle_center_two = create(:cycle_center,
                                center: center, cycle: cycle_two, program_id: 1)

      create(:learner_program, program_id: 1, cycle_center: cycle_center_two,
                               decision_one: "Advanced",
                               decision_two: "Accepted")
      create(:learner_program, program_id: 1, cycle_center: cycle_center_one,
                               decision_one: "Advanced",
                               decision_two: "Accepted")
    end

    scenario "user should see cycle dropdown get populated" do
      visit("/analytics")
      # find("a#skip-tour-btn").click
      find("a#cycle-metrics-tab").click
      sleep 1
      find("span#cycle-dropdown-button").click

      expect(page).to have_content("32")
      expect(page).to have_content("31")
    end
  end
end
