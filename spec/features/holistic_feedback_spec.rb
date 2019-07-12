require "rails_helper"

describe "holistic feedback modal test" do
  before :all do
    program = Program.first
    @learner =
      create(:learner_program, program_id: program.id).bootcamper
  end

  before do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    click_on "Learners"
    learner_name = @learner.first_name + " " + @learner.last_name
    click_link(learner_name)
  end

  feature "holistic feedback modal" do
    scenario "user can submit holistic feedback" do
      find("a.evaluation-select").click
      find(".learner-feedback-btn").click
      find(".holistic-feedback-btn").click
      fill_in("quality", with: "Good")
      fill_in("quantity", with: "Average")
      fill_in("initiative", with: "Excellent")
      fill_in("communication", with: "Extremely Satisfied")
      fill_in("integration", with: "Very Good")
      fill_in("epic", with: "Poor")
      fill_in("learning", with: "Low")

      find(".holistic-feedback-button").click

      expect(page).to have_content("Holistic Feedback saved successfully")
    end

    scenario "user cannot submit holistic feedback without comment" do
      find("a.evaluation-select").click
      find(".learner-feedback-btn").click
      find(".holistic-feedback-btn").click
      find(".holistic-feedback-button").click

      expect(page).to have_content("Comment is required")
    end

    scenario "Criteria descriptions are displayed" do
      find("a.evaluation-select").click
      find(".learner-feedback-btn").click
      find(".holistic-feedback-btn").click
      find("span#Quantity.info-icon").hover

      expect(page).to have_content("The ability to consistently deliver work")
    end
  end
end
