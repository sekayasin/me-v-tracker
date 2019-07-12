module LearningEcosystemHelper
  def set_up_db
    center = create(:center)
    program = create(:program)
    @bootcamper = create :bootcamper
    cycle_center = create(:cycle_center, center: center)
    @learner_program = create :learner_program,
                              camper_id: @bootcamper[:camper_id],
                              cycle_center: cycle_center,
                              program_id: program.id
    @learner_center = @learner_program.cycle_center.cycle_center_details

    @phase = create(:phase)
    create :programs_phase, phase_id: @phase.id,
                            program_id: program.id
    @framework_criterium = create :framework_criterium
    @assessment = create :assessment, :requires_submissions, :long_description,
                         phases: [@phase],
                         framework_criterium: @framework_criterium
    @feedback = create :feedback, learner_program: @learner_program,
                                  phase: @phase,
                                  assessment: @assessment
    @assessments = populate_assessments
  end

  def set_up_gcp
    gcp_connection = GcpService.get_connection("no-bucket")
    gcp_connection.put_bucket(GcpService::LEARNER_SUBMISSIONS_BUCKET)
  end
end
