module DashboardHelper
  def cycles_per_centre(params)
    uniq_centers = Hash.new
    cycle_centers = CycleCenter.includes(
      :center, :cycle
    ).where(validate_date_params(params)).pluck(:name, :cycle)
    cycle_centers.uniq.each do |cycle_center|
      if uniq_centers[cycle_center[0]].nil?
        uniq_centers[cycle_center[0]] = 1
      else
        uniq_centers[cycle_center[0]] += 1
      end
    end
    uniq_centers
  end

  def get_max(date)
    max_date = CycleCenter.where(
      "end_date < '#{Date.today}'"
    ).maximum(date)
    max_date ? max_date.to_date : Date.today
  end

  def get_min(date)
    min_date = CycleCenter.minimum(date)
    min_date&.to_date
  end

  def get_min_max_dates
    [
      get_min("start_date"),
      get_max("start_date"),
      get_min("end_date"),
      get_max("end_date")
    ]
  end

  def all_week2_decisions(params)
    LearnerProgram.where(validate_date_params(params)).
      joins(:cycle_center).
      group(:decision_two).
      count(:decision_two).
      sort_by { |_key, value| value }.
      reverse.to_h.except!(
        "In Progress",
        "Not Applicable"
      )
  end

  def to_percentage(decision_count, total_count)
    (100 * decision_count.to_i.to_f / total_count).round(1)
  end

  def decision_percentages(params, week)
    week_data = {
      decisions: [],
      totals: [],
      percentages: []
    }
    all_decisions = if week == "week_one"
                      program_health_metrics(params).delete_if do |key, _value|
                        key.nil?
                      end
                    else
                      all_week2_decisions(params).delete_if do |key, _value|
                        key.nil?
                      end
                    end

    total_count = all_decisions.values.sum

    all_decisions.each do |decision, decision_count|
      week_data[:decisions] << decision
      week_data[:totals] << decision_count
      week_data[:percentages] << to_percentage(decision_count, total_count)
    end
    week_data
  end

  def learners_dispersion_percentages(params)
    learners_dispersion = {
      centers: [],
      totals: [],
      percentages: [],
      colors: []
    }
    campers_center_count =
      learners_dispersion_data(params).delete_if do |key, _value|
        key.nil?
      end

    total_count = campers_center_count.values.sum

    campers_center_count.each do |center, total|
      learners_dispersion[:centers] << center
      learners_dispersion[:totals] << total
      learners_dispersion[:percentages] << to_percentage(total, total_count)
    end
    learners_dispersion
  end

  def learners_dispersion_data(params)
    CycleCenter.where(
      validate_date_params(params)
    ).joins(
      :center,
      :learner_program
    ).distinct(
      :camper_id
    ).group(
      :name
    ).count(
      :camper_id
    )
  end

  def get_learner_programs_by_location(params)
    cycle_center_ids = CycleCenter.where(
      validate_date_params(params)
    ).pluck(:cycle_center_id)
    learner_programs = LearnerProgram.where(
      cycle_center_id: cycle_center_ids
    ).includes(cycle_center: :center)
    locations = {}
    perceived_readiness = {}
    learner_programs.each do |learner_program|
      center_name = learner_program.cycle_center.center.name
      locations[center_name] = [] unless locations[center_name]
      perceived_readiness = set_center_key(
        perceived_readiness, center_name
      )
      locations[center_name] << learner_program
    end
    perceived_readiness_centers(locations, perceived_readiness)
  end

  def set_center_key(perceived_readiness, center_name)
    unless perceived_readiness[center_name]
      perceived_readiness[center_name] = {
        week_2_ready: 0, week_1_ready: 0, week_1_not_ready: 0,
        week_2_not_ready: 0, total: 0
      }
    end
    perceived_readiness
  end

  def perceived_readiness_centers(locations, perceived_readiness)
    locations.each do |location, learner_programs|
      perceived_readiness[location][:week_2_ready] =
        learner_programs.select do |learner_program|
          learner_program.decision_two == "Accepted"
        end.size
      perceived_readiness[location][:week_1_ready] =
        learner_programs.select do |learner_program|
          learner_program.decision_one == "Advanced"
        end.size
      perceived_readiness[location][:week_1_not_ready] =
        learner_programs.count -
        perceived_readiness[location][:week_1_ready]
      perceived_readiness[location][:week_2_not_ready] =
        perceived_readiness[location][:week_1_ready] -
        perceived_readiness[location][:week_2_ready]
      perceived_readiness[location][:total] =
        perceived_readiness[location][:week_1_ready] +
        perceived_readiness[location][:week_1_not_ready]
    end
    perceived_readiness
  end

  def perceived_readiness_percentages(params)
    perceived_readiness_data = get_learner_programs_by_location(params)
    perceived_readiness_percentages = {
      week_2_ready: [], week_1_not_ready: [], week_2_not_ready: [],
      location: [], week_2_ready_data: [], week_1_not_ready_data: [],
      week_2_not_ready_data: []
    }
    perceived_readiness_data.each do |location, data|
      perceived_readiness_percentages[:week_2_ready] <<
        to_percentage(data[:week_2_ready], data[:total])
      perceived_readiness_percentages[:week_2_ready_data] <<
        data[:week_2_ready]
      perceived_readiness_percentages[:week_1_not_ready] <<
        to_percentage(data[:week_1_not_ready], data[:total])
      perceived_readiness_percentages[:week_1_not_ready_data] <<
        data[:week_1_not_ready]
      perceived_readiness_percentages[:week_2_not_ready] <<
        to_percentage(data[:week_2_not_ready], data[:total])
      perceived_readiness_percentages[:week_2_not_ready_data] <<
        data[:week_2_not_ready]
      perceived_readiness_percentages[:location] << location
    end
    perceived_readiness_percentages
  end
end
