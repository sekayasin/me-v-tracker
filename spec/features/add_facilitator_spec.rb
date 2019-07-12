require "rails_helper"
require "spec_helper"
require "helpers/add_facilitator_helper.rb"
describe "Add Facilitators" do
  include AddFacilitatorHelper
  before :all do
    create_seed_data
  end

  after :all do
    clear_seed_data
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

  feature "add facilitator button" do
    scenario "an admin should see an add-facilitator button" do
      expect(page).to have_selector(".add-lfa")
    end
  end

  feature "add facilitator modal form" do
    scenario "admin should see a modal with add-facilitator form " do
      find(".add-lfa").click
      expect(page).to have_selector("#add-facilitator-modal")
    end

    scenario "users should fill and submit the form successfully" do
      add_facilitator_helper(@camper)
      expect(page).to have_content("Facilitator added successfully.")
    end

    scenario "users should see email validation error" do
      find(".add-lfa").click
      find("div#facilitator-Nigeria").click
      find(".show-second-tab").click
      fill_in("input_fac_email", with: "test.try@gmail.com")
      find(".post-form-request").click

      expect(page).to have_content(
        "Please provide a valid Andela email."
      )
    end

    scenario "users should see appropriate validation errors" do
      find(".add-lfa").click
      find("div#facilitator-Nigeria").click
      find(".show-second-tab").click
      find(".post-form-request").click

      expect(page).to have_content("Select at least one learner")
      expect(page).to have_content("Please select a bootcamp week")
      expect(page).to have_content("The facilitator\'s city is required.")
      expect(page).to have_content("Please provide facilitator\'s email.")
    end
  end
end
