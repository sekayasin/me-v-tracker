module DashboardConcern
  extend ActiveSupport::Concern

  def get_quality_target(program_id, center, cycle)
    target_ids = LearnerProgram.includes(
      :program_years
    ).includes(
      cycle_center: :center
    ).includes(
      cycle_center: :cycle
    ).where(
      program_id: program_id,
      centers: { name: center },
      cycles: { cycle: cycle }
    ).pluck(:target_id)

    Target.select(target_id: target_ids).pluck(
      :performance_target, :output_target
    ).first.map(&:to_i)
  end

  def lfa_to_learner_ratio
    learner_ratio =
      RedisService.get(
        "analytics_lfa_to_learner_#{generate_redis_date_keys(params)}"
      )
    unless learner_ratio
      data_in_params = LearnerProgram.where(
        validate_date_params(params)
      ).joins(:cycle_center)
      learner_ratio = [
        data_in_params.distinct(:week_one_facilitator_id).
          count(:week_one_facilitator_id),
        data_in_params.count,
        data_in_params.distinct(:week_two_facilitator_id).
          count(:week_two_facilitator_id),
        data_in_params.where(decision_one: "Advanced").count(:decision_one)
      ]
      RedisService.set(
        "analytics_lfa_to_learner_#{generate_redis_date_keys(params)}",
        learner_ratio
      )
    end
    learner_ratio
  end

  def to_percentage(individual_count, total_count)
    (100 * individual_count.to_i.to_f / total_count).round(2)
  end

  def lfa_to_learner_percentages
    week_one_totals = lfa_to_learner_ratio[0] + lfa_to_learner_ratio[1]
    week_two_totals = lfa_to_learner_ratio[2] + lfa_to_learner_ratio[3]
    lfa_to_learner_ratio << [
      to_percentage(lfa_to_learner_ratio[0], week_one_totals),
      to_percentage(lfa_to_learner_ratio[1], week_one_totals),
      to_percentage(lfa_to_learner_ratio[2], week_two_totals),
      to_percentage(lfa_to_learner_ratio[3], week_two_totals)
    ]
  end

  def gender_distribution_data(params)
    learner_count =
      LearnerProgram.where(validate_date_params(params)).
      joins(cycle_center: :center).joins(:bootcamper).
      group(:'centers.name', :gender).
      count(:gender)
    prepare_gender_distribution_data(learner_count)
  end

  def percentages(male, female)
    male_percentage = []
    female_percentage = []

    genders = [male, female]
    female = genders.last
    male = genders.first
    male.each_with_index do |count, i|
      male_count = count.to_f
      female_count = female[i].to_f
      percentage = (male_count / (female_count + male_count)) * 100
      male_percentage << percentage.round(2)
      female_percentage << (100.to_f - percentage).round(2)
    end
    [male_percentage, female_percentage]
  end

  def get_learner_programs_by_center(center, cycle, program_id, decisions)
    cycle_center_id = CycleCenter.joins(
      :center, :cycle
    ).where(
      centers: { name: center }, cycles: { cycle: cycle }
    ).first

    LearnerProgram.where(
      decision_one: decisions, program_id: program_id,
      cycle_center_id: cycle_center_id
    )
  end

  private

  def prepare_gender_distribution_data(learner_count)
    female = []
    male = []
    center = []
    learner_count.each do |data, count|
      if data[1] == "Female"
        female << count
      else
        male << count
        center << data[0]
      end
    end
    [male, female, center] + percentages(male, female)
  end
end
