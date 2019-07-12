require "rails_helper"
require "spec_helper"

describe "Edit learner technical details" do
  before :all do
    @program = Program.first || create(:program)
    @bootcamper = create(:bootcamper, email: "vof.learnermail@gmail.com")
    @learner_program = create(
      :learner_program,
      program_id: @program.id,
      camper_id: @bootcamper.camper_id
    )
  end

  after :all do
    BootcampersLanguageStack.where(
      "camper_id = '#{@bootcamper.camper_id}'"
    ).delete_all
    LearnerProgram.where(
      "id = #{@learner_program.id} or camper_id = '#{@bootcamper.camper_id}'"
    ).delete_all
    Bootcamper.where("camper_id = '#{@bootcamper.camper_id}'").delete_all
  end

  before :each do
    stub_non_andelan_bootcamper(@bootcamper)
    stub_current_session_bootcamper(@bootcamper)
    visit("/learner")
  end

  feature "edit learner technical details" do
    scenario "user should see edit learner modal" do
      sleep 1
      find(".technical-details-btn").click
      edit_modal = find("#edit-learner-technical-details-modal")
      expect(edit_modal).to have_content("Edit Technical Details")
      expect(edit_modal).to have_content("Languages/Stacks")
      expect(edit_modal).to have_content("Preferred Languages/Stacks")
    end

    scenario "user should see message on successful update" do
      sleep 1
      find(".technical-details-btn").click
      find("label.input-container:nth-child(3)").click
      find("label.input-container:nth-child(5)").click
      find(".save-edit-learner-technical-details").click
      expect(page).to have_content(
        "Learner technical details updated successfully"
      )
    end

    feature "display learner technical details" do
      scenario "user should see their alc stacks" do
        sleep 1
        expect(page).to have_content(
          @learner_program.dlc_stack.language_stack.name
        )
      end

      scenario "user should see their preferred stacks" do
        sleep 1
        @bootcamper.bootcampers_language_stacks.each do |stack|
          expect(page).to have_content(stack.language_stack.name)
        end
      end
    end
  end
end
