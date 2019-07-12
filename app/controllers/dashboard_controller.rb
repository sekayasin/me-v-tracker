class DashboardController < ApplicationController
  include DashboardControllerHelper

  def index; end

  def cycle_center_metrics
    program_ids = get_program_ids(params[:program_id])
    center = params[:center]
    center_metrics = RedisService.get(
      "analytics_center_metrics_#{params[:program_id]}_#{params[:center]}"
    )
    unless center_metrics
      center_metrics = get_center_matrices(program_ids, center)
      RedisService.set(
        "analytics_center_metrics_#{params[:program_id]}_#{params[:center]}",
        center_metrics
      )
    end
    render json: center_metrics
  end

  def get_center_matrices(program_ids, center)
    cycles = get_finalized_cycles(program_ids, center)
    performance_and_output_quality = performance_and_output_quality(
      program_ids, center, cycles
    ).sort.to_h
    learner_quantity = learner_quantity(program_ids, center, cycles).sort.to_h
    gender_distribution = gender_distribution(program_ids, center, cycles)
    week_one_decisions = center_health_metrics
    week_two_cycle_metrics = cycle_metrics(center, cycles)[:week_two_metrics]
    lfa_learner_ratio = cycle_metrics(center, cycles)[:lfa_ratio]
    lfa_to_learner_percent = cycle_metrics(center, cycles)[:ratio_percentages]
    {
      cycles: cycles,
      learner_quantity: learner_quantity,
      performance_and_output_quality: performance_and_output_quality,
      gender_distribution: gender_distribution,
      week_one_decisions: week_one_decisions,
      week_two_cycle_metrics: week_two_cycle_metrics,
      lfa_learner_ratio: lfa_learner_ratio,
      lfa_to_learner_percent: lfa_to_learner_percent
    }
  end

  def program_metrics
    render json: {
      min_max_dates: get_min_max_dates,
      cycles_per_centre: cycles_per_centre(params),
      phase_two_metrics: decision_percentages(params, "week_two"),
      phase_one_metrics: decision_percentages(params, "week_one"),
      learners_dispersion_data: learners_dispersion_percentages(params),
      lfa_to_learner_ratio: lfa_to_learner_percentages,
      gender_distribution_data: gender_distribution_data(params),
      perceived_readiness_genders: perceived_readiness_genders(params),
      perceived_readiness_percentages: perceived_readiness_percentages(params)
    }
  end

  def program_feedback
    nps_totals = NpsQuestion.all.map do |question|
      ratings = get_question_ratings(question.nps_question_id,
                                     params[:center],
                                     params[:cycle])
      nps_ratings = convert_ratings_hash_to_nps(ratings)

      { title: question.title,
        description: question.description,
        nps_totals: nps_ratings }
    end

    render json: nps_totals
  end

  def program_feedback_centers
    center_cycles = CycleCenter.
                    joins(:nps_responses, :center, :cycle).
                    select("cycles.cycle_id, cycles_centers.cycle_center_id,
                            centers.name, cycles.cycle").
                    where("program_id = ?",
                          params[:program_id]).
                    distinct.inactive

    unique_centers = {}
    center_cycles.each do |center|
      unique_centers[center.name] = [] unless unique_centers[center.name]
      unique_centers[center.name].append center.cycle.cycle
    end
    render json: unique_centers
  end

  def sheet
    respond_to do |format|
      format.csv { generate_report(params[:report_type]) }
    end
  end

  private

  def program_health_metrics(params)
    LearnerProgram.where(validate_date_params(params)).
      joins(:cycle_center).
      group(:decision_one).
      count(:decision_one).
      sort_by { |_key, value| value }.
      reverse.to_h
  end

  def center_health_metrics
    program_id = get_program_ids(params[:program_id])
    center = params[:center]
    week_one_decisions = LearnerProgram.week_one_decisions
    cycles = get_finalized_cycles(program_id, center)
    decision_data = {}

    cycles.each do |cycle|
      decision_data[cycle] = {}
      learner_programs =
        get_learner_programs_by_center(
          center, cycle, program_id, week_one_decisions
        )

      week_one_decisions.each do |decision|
        decision_data[cycle][decision] = {}
        decision_data[cycle][decision]["total_count"] =
          learner_programs.where(decision_one: decision).count
        learner_count = learner_programs.count.to_f
        decision_total_count = decision_data[cycle][decision]["total_count"]
        decision_data[cycle][decision]["percentage"] =
          format("%.1f", ((decision_total_count / learner_count) * 100).to_d)
      end
    end

    decision_data
  end

  def perceived_readiness_genders(params)
    learner_programs = LearnerProgram.includes(:cycle_center).
                       where(validate_date_params(params))
    perceived_readiness_across_genders(learner_programs)
  end
end
