require "rails_helper"
require "spec_helper"

describe "Edit learner personal details" do
  include LearnerProfileHelper

  before :all do
    center = create(:center, name: "Lagos", country: "Nigeria")
    cycle_center = create(:cycle_center, center: center)
    @bootcamper = create(:bootcamper)
    @update_params = build(:bootcamper, username: "voflearner",
                                        phone_number: "08059898798")
    @invalid_params = build(:bootcamper, username: "Vof23,.",
                                         phone_number: "08045608954er")
    @learner_program = if @bootcamper.nil?
                         {}
                       else
                         create :learner_program,
                                camper_id: @bootcamper[:camper_id],
                                cycle_center: cycle_center
                       end
    @learner_center = @learner_program.cycle_center.cycle_center_details
  end

  before(:each) do
    stub_non_andelan_bootcamper(@bootcamper)
    stub_current_session_bootcamper(@bootcamper)
    visit("/learner")
  end

  feature "redirect to learner's profile page" do
    scenario "three sections should exist on page" do
      sleep 1
      expect(page).to have_content("Personal Details")
      expect(page).to have_content("Technical Details")
      expect(page).to have_content("History")
    end
  end

  feature "edit personal details modal popup" do
    scenario "modal visible fields are pre-populated" do
      sleep 1
      find(".edit-personal-details-modal").click
      fields = %w(
        username
        phone_number
        github
        linkedin
        trello
        website
      )

      fields.each do |field|
        expect(page).to have_field(field.to_s, with: @bootcamper[field.to_sym])
      end
      expect(page).to have_field(
        "about", type: "textarea", with: @bootcamper["about"], visible: false
      )
    end

    scenario "modal diabled text fields and select fields are pre-populated" do
      sleep 1
      find(".edit-personal-details-modal").click
      fields = %w(first_name last_name middle_name)
      fields.each do |field|
        expect(page).to have_field(
          field, with: @bootcamper[field.to_s], disabled: true
        )
      end
      expect(page).to have_select(
        "gender", selected: @bootcamper[:gender], disabled: true, visible: false
      )
      expect(page).to have_select("country", disabled: true, visible: false)
      expect(page).to have_select("city", disabled: true, visible: false)
    end
  end

  feature "update personal details with no changes" do
    scenario "message 'No change has been made' is seen" do
      sleep 1
      find(".edit-personal-details-modal").click
      sleep 0.5
      page.evaluate_script("$('#update-personal-details').click()")
      expect(page).to have_content("No change has been made")
    end
  end

  feature "update personal details after making changes" do
    scenario "update should be successful" do
      sleep 1
      find(".edit-personal-details-modal").click
      sleep 0.5
      fill_in("username", with: @update_params[:username])
      fill_in("phone_number", with: @update_params[:phone_number])
      page.evaluate_script("$('#country-dropdown').prop('disabled', false)")
      page.evaluate_script("$('#city-dropdown').prop('disabled', false)")
      page.evaluate_script("$('#gender-dropdown').prop('disabled', false)")
      sleep 0.5
      page.evaluate_script("$('#update-personal-details').click()")
      expect(page).to have_content(@update_params[:username])
      expect(page).to have_content(@update_params[:phone_number])
    end

    scenario "update should fail with errors" do
      sleep 1
      find(".edit-personal-details-modal").click
      sleep 0.5
      fill_in("username", with: @invalid_params[:username])
      fill_in("phone_number", with: @invalid_params[:phone_number])
      page.evaluate_script("$('#update-personal-details').click()")
      sleep 0.5
      expect(page).to have_content("Enter a valid username")
      expect(page).to have_content("Enter a valid phone number")
    end
  end
end
