class HolisticEvaluationsController < ApplicationController
  include HolisticEvaluationsControllerHelper

  before_action :authorize_create, only: :create

  def create
    create_holistic_evaluation
    eligibility_status = eligibility_status(params[:learner_program_id])
    flash[:notice] = "evaluation-success"

    render json: {
      eligible: eligibility_status[:eligible],
      evaluations_received: eligibility_status[:evaluations_received]
    }
  rescue StandardError => e
    message = YAML.parse(e.message).to_ruby.first.second.split(/, /).first
    flash[:error] = message
  end

  def update
    learner_program_details = get_learner_program_details(
      params[:learner_program_id]
    )
    if helpers.can_edit_scores?(
      learner_program_details[:camper_id],
      learner_program_details[:cycle_center_id]
    ) && authorize_update(learner_program_details[:camper_id])
      holistic_evaluation_updated = update_holistic_evaluation
      if holistic_evaluation_updated
        render json: { updated: holistic_evaluation_updated,
                       status: true }
      end
    else
      render json: { updated: false }, status: 401
    end
  end

  def eligibility
    eligibility_status = eligibility_status(params[:learner_program_id])

    render json: { eligible: eligibility_status[:eligible] }
  end

  def holistic_average
    holistic_evaluation_details = get_holistic_evaluations_details(
      params[:learner_program_id]
    )
    learner_program_details = get_learner_program_details(
      params[:learner_program_id]
    )
    render json: {
      holistic_evaluation_details: holistic_evaluation_details,
      can_edit_scores: helpers.can_edit_scores?(
        learner_program_details[:camper_id],
        learner_program_details[:cycle_center_id]
      )
    }
  end

  def holistic_criteria_averages
    render json: get_holistic_criteria_averages(params[:learner_program_id])
  end

  def get_learner_program_details(learner_program_id)
    learner_program = LearnerProgram.find(learner_program_id)
    { camper_id: learner_program.camper_id,
      cycle_center_id: learner_program.cycle_center_id }
  end

  def generate_learner_holistic_evaluation_report
    holistic_evaluation_details = get_holistic_evaluations_details(
      params[:learner_program_id]
    )
    camper = Bootcamper.where(camper_id: params[:camper_id]).
             select(:first_name, :last_name).first
    camper_name = camper.first_name.downcase
    data_sheet = BootcampersCsvService

    unless holistic_evaluation_details.nil?
      respond_to do |format|
        format.js
        format.html
        format.csv do
          send_data data_sheet.generate_holistic_evaluation_report(
            holistic_evaluation_details, camper
          ), filename: "#{camper_name}-holistic-evaluation-#{Date.today}.csv"
        end
      end
    end
  end

  def holistic_criteria_info
    criteria_info =
      RedisService.get("analytics_h_criteria_#{params[:program_id]}")
    unless criteria_info
      criteria = Criterium.get_program_criteria(params[:program_id])
      metrics = Point.get_criteria_points_metrics(params[:program_id])

      criteria_info = {
        criteria: criteria,
        metrics: metrics
      }
      RedisService.set(
        "analytics_h_criteria_#{params[:program_id]}", criteria_info
      )
    end

    render json: criteria_info
  end

  private

  def get_holistic_criteria_averages(learner_program_id)
    calculate_criteria_averages(
      holistic_score_details(learner_program_id)
    )
  end

  def holistic_score_details(learner_program_id)
    holistic_evaluations = HolisticEvaluation.get_evaluations(
      learner_program_id
    )

    prepare_evaluation_details holistic_evaluations
  end

  def create_holistic_evaluation
    holistic_evaluation = params.to_unsafe_h[:holistic_evaluation]

    holistic_scores = HolisticEvaluation.
                      parse_evaluation_scores(holistic_evaluation)

    dev_framework_scores = HolisticEvaluation.
                           parse_evaluation_scores(holistic_evaluation, true)

    averages_record = EvaluationAverage.
                      save_evaluation_averages(
                        holistic_scores,
                        dev_framework_scores,
                        params[:learner_program_id]
                      )

    HolisticEvaluation.save_holistic_evaluations(
      holistic_evaluation,
      params[:learner_program_id],
      averages_record.id
    )
  end

  def update_holistic_evaluation
    holistic_evaluation = params.to_unsafe_h[:holistic_evaluation]
    HolisticEvaluation.update_holistic_evaluations(
      holistic_evaluation
    )
  end

  def get_holistic_evaluations_details(learner_program_id)
    holistic_evaluations = HolisticEvaluation.get_evaluations(
      learner_program_id
    )

    unless holistic_evaluations.empty?
      criteria_by_submission = []
      evaluation_groups = split_holistic_evaluation(holistic_evaluations)

      evaluation_groups.each do |evaluation|
        criteria_by_submission << get_prepared_scores_history(evaluation)
      end
      criteria_by_submission.reverse
    end
  end
end
