require "rails_helper"

describe "personal feedback modal test" do
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
  end

  feature "personal feedback modal" do
    scenario "user can view personal feedback modal" do
      camper_name = @learner.first_name + " " + @learner.last_name
      click_link(camper_name)
      find("a.evaluation-select").click
      find(".learner-feedback-btn").click
      find(".personal-feedback-btn").click

      modal_header = first(".personal-feedback-modal-header")
      expect(modal_header).to have_content("Feedback Schema")
    end

    scenario "user can submit personal feedback" do
      camper_name = @learner.first_name + " " + @learner.last_name
      click_link(camper_name)

      find("a.evaluation-select").click
      find(".learner-feedback-btn").click
      find(".personal-feedback-btn").click
      find("#learner-output-button").click
      find(:css, ".ui-selectmenu-open .ui-menu-item:nth-child(2)").click
      find("#learner-impression-button").click
      find(:css, ".ui-selectmenu-open .ui-menu-item:nth-child(2)").click
      fill_in("comment", with: "Good")

      find("#personal-feedback-submit-btn").click

      expect(page).to have_content("Feedback successfully saved")
    end

    scenario "user cannot submit personal feedback without output" do
      camper_name = @learner.first_name + " " + @learner.last_name
      click_link(camper_name)

      find("a.evaluation-select").click
      find(".learner-feedback-btn").click
      find(".personal-feedback-btn").click
      find("#learner-impression-button").click
      find(".ui-menu-item", text: "Extremely Satisfied").click
      fill_in("comment", with: "Good")

      find("#personal-feedback-submit-btn").click

      expect(page).to have_content("Please select an output")
    end
  end
end
