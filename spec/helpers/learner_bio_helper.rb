module LearnerBioHelper
  def set_up
    program = Program.first
    cycle = create(:cycle)
    @old_center = create(:center)
    cycle_center = create(
      :cycle_center,
      cycle: cycle,
      center: @old_center,
      program_id: program.id
    )
    @bootcamper = create(:bootcamper)
    create(
      :learner_program,
      cycle_center: cycle_center,
      program_id: program.id,
      camper_id: @bootcamper.camper_id
    )
    @new_center = create(:center)
    @new_email = "testuser@gmail.com"
  end

  def tear_down
    LearnerProgram.where(
      camper_id: @bootcamper.camper_id
    ).delete_all
    @bootcamper.delete
    @old_center.delete
    @new_center.delete
  end
end
