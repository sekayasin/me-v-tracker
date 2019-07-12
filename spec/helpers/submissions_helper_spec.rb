module SubmissionsHelper
  def first_db_setup
    @program = create(:program)
    @bootcamper = create(:bootcamper)
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
    @learner_program = create(
      :learner_program,
      program_id: @program.id,
      cycle_center_id: @cycle_center.cycle_center_id,
      camper_id: @bootcamper.camper_id,
      week_one_facilitator_id: @week_one_lfa.id,
      week_two_facilitator_id: @week_two_lfa.id
    )
    @phase = create(:phase)
    @program_phase = create(
      :programs_phase,
      phase_id: @phase.id,
      program_id: @program.id
    )
    @framework_criterium = create :framework_criterium
    @assessment = create(
      :assessment,
      :requires_submissions,
      :long_description,
      phases: [@phase],
      framework_criterium_id: @framework_criterium.id
    )
  end

  def third_db_setup
    LearnerProgram.update(@learner_program.id, decision_one: "Rejected")
  end
end
