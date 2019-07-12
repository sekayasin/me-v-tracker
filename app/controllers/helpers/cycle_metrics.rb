class CycleMetrics
  def initialize(center, cycles)
    @center = center
    @cycles = cycles
  end

  def get_week_two_cycle_metrics
    metrics = {}
    @cycles.each do |cycle|
      metrics[cycle] = {}
      metrics[cycle][:totals] = query_week_two_cycle_metrics(cycle)
      metrics[cycle][:percentage] = get_percentages(metrics[cycle][:totals])
      metrics[cycle][:labels] = metrics[cycle][:totals].keys
      metrics[cycle][:labels].delete(nil)
      metrics[cycle][:totals].delete(nil)
      metrics[cycle][:percentage].delete(nil)
    end
    metrics
  end

  def get_percentages(totals)
    total_sum = totals.values.sum.to_f
    percentages = {}
    totals.each do |key, value|
      percentages[key] = ((value.to_f / total_sum) * 100).round(2)
    end
    percentages
  end

  def query_week_two_cycle_metrics(cycle)
    LearnerProgram.where(
      centers: { name: @center },
      cycles: { cycle: cycle }
    ).joins(
      cycle_center: :center
    ).joins(
      cycle_center: :cycle
    ).group(
      :decision_two
    ).count(
      :decision_two
    ).except!(
      "Not Applicable",
      "In Progress"
    )
  end

  def lfa_ratio(center, cycles)
    data = LearnerProgram.joins(cycle_center: :cycle).joins(
      cycle_center: :center
    ).where(
      centers: { name: center },
      cycles: { cycle: cycles }
    )
    {
      week_one_lfas: data.distinct(:week_one_facilitator_id).group(
        :'cycles.cycle'
      ).count(:week_one_facilitator_id),
      week_one_learners: data.group(:'cycles.cycle').count,
      week_two_lfas: data.distinct(
        :week_two_facilitator_id
      ).group(:'cycles.cycle').count(:week_two_facilitator_id),
      week_two_learners: data.where(
        decision_one: "Advanced"
      ).group(:'cycles.cycle').count
    }
  end

  def to_percentage(individual_count, total_count)
    (100 * individual_count.to_f / total_count.to_f).round(2)
  end

  def lfa_ratio_percentages(center, cycles)
    counts = lfa_ratio(center, cycles)
    percentages = {}

    cycles.each do |cycle|
      week_one_total =
        counts[:week_one_lfas][cycle] + counts[:week_one_learners][cycle]
      week_two_total =
        counts[:week_two_lfas][cycle] + counts[:week_two_learners][cycle]

      percentages[cycle] = {}
      percentages[cycle][:week_one_lfa] = to_percentage(
        counts[:week_one_lfas][cycle], week_one_total
      )
      percentages[cycle][:week_one_learner] = to_percentage(
        counts[:week_one_learners][cycle],
        week_one_total
      )
      percentages[cycle][:week_two_lfa] = to_percentage(
        counts[:week_two_lfas][cycle],
        week_two_total
      )
      percentages[cycle][:week_two_learner] = to_percentage(
        counts[:week_two_learners][cycle],
        week_two_total
      )
    end
    percentages
  end
end
