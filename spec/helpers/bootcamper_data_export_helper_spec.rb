module BootcamperDataExportHelper
  def first_db_setup
    @center = create(:center)
    @bootcamper_one = create(:bootcamper)
    @bootcamper_two = create(:bootcamper)
    @program = Program.first || create(:program, save_status: true)
    @cycle = create(:cycle)
    @center = create(:center)
    @cycle_center = create(
      :cycle_center,
      :ongoing,
      center_id: @center.center_id,
      cycle_id: @cycle.cycle_id,
      program_id: @program.id
    )
    @week_one_lfa = create(:facilitator)
    @week_two_lfa = create(:facilitator)
  end

  def second_db_setup
    @learner_program_one = create(
      :learner_program,
      program: @program,
      cycle_center: @cycle_center,
      camper_id: @bootcamper_one.camper_id
    )
    @learner_program_two = create(
      :learner_program,
      program: @program,
      cycle_center: @cycle_center,
      camper_id: @bootcamper_two.camper_id
    )
    @phase = create(:phase)
    @program_phase = create(
      :programs_phase,
      phase_id: @phase.id,
      program_id: @program.id
    )
    @decision = create(
      :decision,
      learner_program: @learner_program_one
    )
  end
end
