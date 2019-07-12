module EvaluationEligibility
  extend ActiveSupport::Concern

  def holistic_evaluations_received
    scores_saved = HolisticEvaluation.get_scores(id).length
    program_criteria = Criterium.get_program_criteria(program).to_a.length
    scores_saved / program_criteria
  rescue ZeroDivisionError
    0
  end

  def max_holistic_evaluations
    program.estimated_duration / program.cadence.days
  rescue ZeroDivisionError
    0
  end

  def can_be_evaluated?
    holistic_evaluations_received < max_holistic_evaluations
  end
end
