module DecisionHistoryHelpers
  def set_up
    @program = Program.first
    @first_bootcamper = create(:bootcamper)
    @cycle_center = create(:cycle_center, program_id: @program.id)
    @first_learner_program = create(:learner_program,
                                    program_id: @program.id,
                                    decision_one: "In Progress",
                                    decision_two: "Not Applicable",
                                    cycle_center: @cycle_center,
                                    camper_id: @first_bootcamper.camper_id)
    @second_bootcamper = create(:bootcamper)
    @learner_program = create(
      :learner_program,
      decision_one: "Advanced",
      decision_two: "Accepted",
      camper_id: @second_bootcamper.camper_id,
      program_id: @program.id,
      cycle_center: @cycle_center
    )

    @decision = create(
      :decision,
      learner_programs_id: @learner_program.id
    )
  end
end
