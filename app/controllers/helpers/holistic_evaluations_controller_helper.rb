module HolisticEvaluationsControllerHelper
  def split_holistic_evaluation(holistic_evaluations)
    criteria = holistic_evaluations.map do |evaluation|
      evaluation.criterium.name
    end
    unique_criteria_size = criteria.uniq.length
    holistic_evaluations.each_slice(unique_criteria_size).to_a
  end

  def prepare_evaluation_details(
    holistic_evaluations,
    evaluations_details = {}
  )
    holistic_evaluations.each do |holistic_evaluation|
      criterium = holistic_evaluation.criterium.name

      if evaluations_details.key?(criterium.to_sym)
        evaluations_details[criterium.to_sym] << holistic_evaluation.score
      else
        evaluations_details[criterium.to_sym] = [holistic_evaluation.score]
      end
    end

    evaluations_details
  end

  def calculate_criteria_averages(holistic_evaluation_details)
    holistic_averages = holistic_evaluation_details.map do |criterium, scores|
      [criterium, (scores.inject(:+).to_f / scores.size).round(1)]
    end

    holistic_averages.to_h
  end

  def calculate_submission_average(holistic_evaluations)
    sum = holistic_evaluations.map(&:score).sum
    size = holistic_evaluations.length

    sum / size.round(1)
  end

  def get_prepared_scores_history(holistic_evaluations)
    holistic_average = calculate_submission_average(holistic_evaluations)

    evaluations_details = {}

    holistic_evaluations.each do |holistic_evaluation|
      criterium = holistic_evaluation.criterium.name
      evaluations_details[criterium.to_sym] = {
        id: holistic_evaluation.id,
        criterium_id: holistic_evaluation.criterium.id,
        score: holistic_evaluation.score,
        comment: holistic_evaluation.comment
      }
    end

    prepare_scores_history_details(
      holistic_evaluations,
      evaluations_details,
      holistic_average
    )
  end

  def prepare_scores_history_details(
    holistic_evaluations,
    evaluations_details,
    holistic_average
  )
    {
      average: holistic_average.blank? ? "N/A" : holistic_average.to_f.round(1),
      created_at: {
        date: holistic_evaluations[0].created_at.strftime("%B %e, %Y"),
        time: holistic_evaluations[0].created_at.strftime("%H:%M:%S GMT")
      },
      details: evaluations_details
    }
  end

  def eligibility_status(learner_program_id)
    learner_program = LearnerProgram.find_by(id: learner_program_id)

    if learner_program.nil?
      {
        eligible: false,
        evaluations_received: 0
      }
    else
      {
        eligible: learner_program.can_be_evaluated?,
        evaluations_received: learner_program.holistic_evaluations_received
      }
    end
  end

  def authorize_create
    learner_program = LearnerProgram.find(params[:learner_program_id])
    unless helpers.user_is_lfa_or_admin?(params[:id]) && \
           learner_program.can_be_evaluated?
      head :unauthorized
    end
  end

  def authorize_update(camper_id)
    if !helpers.user_is_lfa_or_admin?(camper_id)
      head :unauthorized
    else
      helpers.user_is_lfa_or_admin?(camper_id)
    end
  end
end
