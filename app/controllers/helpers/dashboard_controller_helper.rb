module DashboardControllerHelper
  include DashboardConcern
  include DashboardHelper
  def get_gender_count(program_id, center, cycle, gender)
    LearnerProgram.get_gender_count(program_id, center, cycle, gender)
  end

  def get_program_ids(program_id)
    Program.where(id: program_id).select(&:save_status?).pluck(:id)
  end

  def get_finalized_cycles(program_id, center)
    LearnerProgram.where(centers: { name: center }, program_id: program_id).
      where.not(decision_two: ["In Progress", "Not Applicable"]).
      joins(cycle_center: :cycle).
      joins(cycle_center: :center).distinct.pluck(:cycle).sort.reverse
  end

  def get_learner_quantity(program_id, center, cycle, gender)
    get_gender_count(program_id, center, cycle, gender).
      where(decision_two: "Accepted").count
  end

  def learner_quantity(program_id, center, cycles)
    learner_quantity = {}
    cycles.first(6).each do |cycle|
      male_count = get_learner_quantity(program_id, center, cycle, "Male")
      female_count = get_learner_quantity(program_id, center, cycle, "Female")
      learner_quantity[cycle] = {
        total: male_count + female_count,
        male: male_count,
        female: female_count
      }
    end
    learner_quantity
  end

  def performance_and_output_quality(program_id, center, cycles)
    performance_and_output_quality = {}
    cycles.first(6).each do |cycle|
      performance_and_output_quality[cycle] = {
        target: get_quality_target(program_id, center, cycle),
        holistic_performance_average: LearnerProgram.
                                              evaluations_of_cycle_in_city(
                                                program_id, "holistic_average",
                                                center, cycle
                                              ).to_f.round(2),
        developer_framework_average: LearnerProgram.
                                              evaluations_of_cycle_in_city(
                                                program_id,
                                                "dev_framework_average",
                                                center, cycle
                                              ).to_f.round(2),
        output_average: LearnerProgram.
                                              average_of_cycle_in_city(
                                                program_id, "output_average",
                                                center, cycle
                                              ).to_f.round(2)
      }
    end
    performance_and_output_quality
  end

  def gender_distribution(program_id, center, cycles)
    gender_distribution = {}
    cycles.each do |cycle|
      males = get_gender_count(program_id, center, cycle, "Male").count
      females = get_gender_count(program_id, center, cycle, "Female").count
      accepted_males = get_learner_quantity(program_id, center, cycle, "Male")
      accepted_females = get_learner_quantity(program_id,
                                              center,
                                              cycle,
                                              "Female")
      gender_distribution[cycle] = {
        total: males + females,
        male: males,
        female: females,
        total_accepted: accepted_males + accepted_females,
        num_accepted_males: accepted_males,
        num_accepted_females: accepted_females
      }
    end
    gender_distribution
  end

  def create_cycle_metrics(center, cycles)
    CycleMetrics.new(center, cycles)
  end

  def cycle_metrics(center, cycles)
    {
      week_two_metrics: create_cycle_metrics(
        center, cycles
      ).get_week_two_cycle_metrics,
      lfa_ratio: create_cycle_metrics(center, cycles).lfa_ratio(center, cycles),
      ratio_percentages: create_cycle_metrics(
        center, cycles
      ).lfa_ratio_percentages(center, cycles)
    }
  end

  def generate_report(report_type)
    data = get_report_data(report_type)
    file_name = Dashboard::DashboardFacade.new(report_type, data).
                generate_report
    File.open(file_name, "r") do |file|
      send_data(file.read, type: "application/zip", filename: file_name,
                           disposition: "attachment")
    end
    File.delete(file_name)
  end

  private

  def get_report_data(report_type)
    return get_program_metrics_data if report_type == "program_metrics"

    get_cycle_and_center_metrics_data if report_type == "cycle_metrics"
  end

  def get_program_metrics_data
    {
      gender_distribution_data: gender_distribution_data(params),
      lfa_to_learner_ratio: lfa_to_learner_percentages,
      cycles_per_centre: cycles_per_centre(params),
      phase_two_metrics: decision_percentages(params, "week_two"),
      phase_one_metrics: decision_percentages(params, "week_one"),
      learners_dispersion_data: learners_dispersion_percentages(params),
      start_date: params[:start_date],
      end_date: params[:end_date],
      perceived_readiness_percentages: perceived_readiness_percentages(params)
    }
  end

  def get_cycle_and_center_metrics_data
    program_ids = get_program_ids(params[:program_id])
    center = params[:center]
    cycles = get_finalized_cycles(program_ids, center)
    cycle_metrics = cycle_metrics(center, cycles)
    {
      cycle: params[:cycle],
      center: center,
      program_id: params[:program_id],
      week_one_decisions: center_health_metrics,
      program_ids: program_ids,
      cycles: cycles,
      performance_and_output_quality: performance_and_output_quality(
        program_ids, center, cycles
      ).sort.to_h,
      learner_quantity: learner_quantity(program_ids, center, cycles).
        sort.to_h,
      gender_distribution: gender_distribution(program_ids, center, cycles),
      lfa_learner_ratio: cycle_metrics[:lfa_ratio],
      lfa_to_learner_percent: cycle_metrics[:ratio_percentages],
      week_two_cycle_metrics: cycle_metrics[:week_two_metrics]
    }
  end

  def validate_date_params(params)
    if params[:program_id] == "1"
      "cycles_centers.program_id = '#{params[:program_id]}'"

    elsif params[:start_date].present? && params[:end_date].present?
      "cycles_centers.end_date BETWEEN '#{params[:start_date].to_date}'
        AND '#{params[:end_date].to_date}'"

    else
      "cycles_centers.end_date < '#{Date.today}' AND
        cycles_centers.start_date >= '#{get_min_max_dates[0]}' AND
        cycles_centers.end_date <= '#{get_min_max_dates[3]}' AND
        cycles_centers.program_id = '#{params[:program_id]}'"
    end
  end

  def generate_redis_date_keys(params)
    if params[:program_id] == "1"
      "program_id_1"
    elsif params[:start_date].present? && params[:end_date].present?
      "start_date_#{params[:start_date]}_end_date_#{params[:end_date]}"
    else
      "start_date_min_max_end_date_min_max"
    end
  end

  def perceived_readiness_across_genders(learner_programs)
    readiness_data = {}
    all_learners = learner_programs.includes(:bootcamper).pluck("gender")
    readiness_data[:total_male] = all_learners.count("Male")
    readiness_data[:total_female] = all_learners.count("Female")
    readiness_data[:wk1_ready] =
      learner_programs.where(decision_one: "Advanced").
      includes(:bootcamper).pluck("gender")
    readiness_data[:wk2_ready] =
      learner_programs.
      where(decision_one: "Advanced", decision_two: "Accepted").
      includes(:bootcamper).pluck("gender")
    readiness_data[:wk1_ready_male] = readiness_data[:wk1_ready].count("Male")
    readiness_data[:wk1_ready_female] =
      readiness_data[:wk1_ready].count("Female")
    perceived_readiness_across_genders_result(readiness_data)
  end

  def perceived_readiness_across_genders_result(data)
    result = {}
    result[:wk1_not_ready_male] = data[:total_male] - data[:wk1_ready_male]
    result[:wk2_ready_male] = data[:wk2_ready].count("Male")
    result[:wk2_not_ready_male] = data[:wk1_ready_male] -
                                  result[:wk2_ready_male]
    result[:wk1_not_ready_male_pc] =
      to_percentage(result[:wk1_not_ready_male], data[:total_male])
    result[:wk2_not_ready_male_pc] =
      to_percentage(result[:wk2_not_ready_male], data[:total_male])
    result[:wk2_ready_male_pc] =
      to_percentage(result[:wk2_ready_male], data[:total_male])
    result[:wk1_not_ready_female] =
      data[:total_female] - data[:wk1_ready_female]
    result[:wk2_ready_female] = data[:wk2_ready].count("Female")
    result[:wk2_not_ready_female] = data[:wk1_ready].count("Female") -
                                    result[:wk2_ready_female]
    result[:wk1_not_ready_female_pc] =
      to_percentage(result[:wk1_not_ready_female], data[:total_female])
    result[:wk2_not_ready_female_pc] =
      to_percentage(result[:wk2_not_ready_female], data[:total_female])
    result[:wk2_ready_female_pc] =
      to_percentage(result[:wk2_ready_female], data[:total_female])
    result
  end

  def get_question_ratings(question_id, center_name, cycle)
    NpsResponse.
      joins(:nps_rating, cycle_center: %i(center cycle)).
      where("nps_responses.nps_question_id = ? AND name = ? AND cycle = ?",
            question_id, center_name, cycle).
      group(:rating).count
  end

  def convert_ratings_hash_to_nps(hash)
    nps_data = [0, 0, 0]
    hash.each do |score, count|
      case score
      when 0..6
        nps_data[0] += count
      when 7..8
        nps_data[1] += count
      when 9..10
        nps_data[2] += count
      else
        nps_data = nps_data
      end
    end
    nps_data
  end
end
