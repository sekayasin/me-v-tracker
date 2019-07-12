module ProfileHelper
  def set_up
    @first_program = Program.first
    @second_program = create(:program)
    @bootcamper = create(:bootcamper)
    @criterium = Criterium.first
    @first_learner_program = create(:learner_program,
                                    program: @first_program,
                                    camper_id: @bootcamper.id)

    @second_learner_program = create(:learner_program,
                                     camper_id: @bootcamper.id,
                                     program: @second_program)

    @second_bootcamper =
      create(:learner_program, program_id: @first_program.id).bootcamper

    @assessment = Assessment.first
    @point = Point.first
    @metric = create(:metric, assessment: @assessment, point: @point)

    @holistic_evaluation = create_list(
      :holistic_evaluation,
      3,
      criterium_id: @criterium.id,
      comment: Faker::Lorem.paragraph,
      learner_program_id: @second_bootcamper.learner_programs[0].id
    )
  end
end
