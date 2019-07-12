module ProgramHelpers
  def create_finalised_program
    @program = create(:program, save_status: true)
  end

  def fill_and_submit_form(program_name, program_phase)
    within("#create-program-modal") do
      fill_in("program_name", with: program_name)
      fill_in("program_description", with: Faker::Lorem.paragraph)
      fill_in("program_phase", with: program_phase).native.send_keys(:return)
      click_button "Save"
    end
  end
end
