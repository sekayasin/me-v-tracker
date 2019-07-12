require "rails_helper"
require "spec_helper"

describe "Curriculum page test" do
  before(:each) do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    visit("/curriculum")
  end

  feature "switching tabs" do
    scenario "user should see the tabs on the curriculum page" do
      sleep 1
      expect(page).to have_content("Learning Outcomes")
      expect(page).to have_content("Criteria")
      expect(page).to have_content("Framework")
      expect(page).to have_content("Program Details")
    end
  end

  feature "view learning outcomes" do
    scenario "user should see a table displaying learning outcomes" do
      find(".learning-outcomes-panel").click
      expect(page).to have_content("Outcome")
      expect(page).to have_content("Description")
      expect(page).to have_content("Context")
    end

    scenario "user should be able to filter the learning outcomes table" do
      find(".learning-outcomes-panel").click
      page.all("span.ui-selectmenu-text")[1].click
      find("li", text: "Values Alignment").click
      expect(page).to have_content("Values Alignment")
    end
  end

  feature "view program details section" do
    scenario "user should see a section showing the program details" do
      sleep 1
      find(".program-tab").click
      first_phase_section = first(".program-phase")
      expect(page).to have_content("Est. Duration of Program:")
      expect(page).to have_content("Language(s)/Stack(s):")
      expect(page).to have_content("Holistic Evaluation:")
      expect(first_phase_section.find(".phase-number")).to have_content("1")
    end

    scenario "user should be able to switch phase and see the details" do
      sleep 1
      find(".program-tab").click
      page.all(".upcoming-phase")[1].click
      expect(page).to have_selector(".program-details-row-wrapper td ul")
    end
  end
end
