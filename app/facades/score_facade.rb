class ScoreFacade
  attr_reader :bootcamper, :learner_program

  def initialize(learner_program_id)
    @bootcamper = Bootcamper.includes(:learner_programs).where(
      learner_programs: {
        id: learner_program_id
      }
    ).first
    @learner_program = bootcamper.learner_programs.first
  end

  def get_learner
    [@bootcamper, @learner_program]
  end
end
