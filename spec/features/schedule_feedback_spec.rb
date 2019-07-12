require "rails_helper"
require "spec_helper"

describe "Schedule feedback page" do
  before :all do
    @program = Program.first
    @cycle_center = create(
      :cycle_center,
      :ongoing
    )
    @cycle_center.program = @program
    @cycle_center.save
    @nps_question1 = create(:nps_question)
    @nps_question2 = create(:nps_question)
  end

  feature "Admin View" do
    before(:each) do
      stub_admin_data_success
      stub_andelan
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/surveys")
      find("#schedule-feedback-btn").click
    end

    it "can view feedback schedule modal" do
      expect(page).to have_content("Schedule Feedback")
      expect(page).to have_content("Program")
      expect(page).to have_content("Center")
      expect(page).to have_content("Cycle")
      expect(page).to have_content("Question")
      expect(page).to have_content("Start Date")
      expect(page).to have_content("End Date")
    end

    it "can submit feedback schedule" do
      find("#select_program-button").click
      page.all(".ui-menu-item")[1].click
      find("#select_center-button").click
      page.all(".ui-menu-item")[1].click
      find("#select_cycle-button").click
      page.all(".ui-menu-item")[1].click
      find("#select_question-button").click
      page.all(".ui-menu-item")[1].click
      fill_in("select_start_date_feedback", with: "12 Dec 2018 10:29")
      fill_in("select_end_date_feedback", with: "22 Dec 2018 10:29")
      find("#schedule-feedback-button").click
      expect(page).to have_content("Feedback scheduled")
    end

    it "cannot submit with empty fields" do
      find("#schedule-feedback-button").click
      expect(page).to have_content("Fill all form fields")
    end

    it "cannot select date beyond cycle duration" do
      fill_in("select_start_date_feedback", with: "11 Dec 2018 10:29").disabled?
      fill_in("select_end_date_feedback", with: "23 Dec 2018 10:29").disabled?
    end
  end
end
