require "rails_helper"
require "spec_helper"

describe "Update Learners LFA" do
  include LearnerPageHelper

  before :all do
    @program = Program.first

    @first_bootcamper = create(:bootcamper)
    @week_one_lfa = create(:facilitator, email: "oluwatomi.duyile@andela.com")
    @learner_program = create(
      :learner_program,
      decision_one: "Advanced",
      camper_id: @first_bootcamper.camper_id,
      program_id: @program.id,
      week_one_facilitator: @week_one_lfa
    )
  end

  before do
    stub_andelan
    stub_current_session
    toggle_lfa_columns
    page.driver.
      execute_script("document.querySelector('.lfa-week-2').scrollIntoView()")
  end

  feature "Selecting LFA from dropdown" do
    scenario "user should see success message when LFA one is updated" do
      find(".lfa-week-1-input", match: :first).click
      find(".lfa-1-item", match: :first).click
      expect(page).to have_content "Learner's LFA was updated successfully"
    end

    scenario "user should see success message when LFA two is updated" do
      find(".lfa-week-2-input", match: :first).click
      find(".lfa-2-item", match: :first).click
      expect(page).to have_content "Learner's LFA was updated successfully"
    end

    xscenario "lfa dropdowns should be disabled if user is not admin" do
      stub_andelan_non_admin
      stub_current_session_non_admin
      toggle_lfa_columns
      page.driver.
        execute_script "document.querySelector('.lfa-week-2').scrollIntoView()"
      expect(find(".lfa-week-1-input", match: :first)[:disabled]).to eq "true"
      expect(find(".lfa-week-2-input", match: :first)[:disabled]).to eq "true"
    end
  end

  feature "LFA notification" do
    scenario "lfa should receive new learner notification" do
      find("a.notifications-trigger").click
      expect(page).to have_content("You have been assigned a new Learner")
    end
  end
end
