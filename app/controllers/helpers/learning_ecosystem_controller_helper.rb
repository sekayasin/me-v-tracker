module LearningEcosystemControllerHelper
  def phase_metrics(phase, completed, total)
    {
      id: phase.id,
      name: phase.name,
      completed: completed,
      total: total,
      percentage: get_percentage(completed, total)
    }
  end

  def completed_submissions(phase, learner_program_id)
    phase.output_submissions.where(
      learner_programs_id: learner_program_id
    ).size
  end

  def group_phases(phases, learner_program_id)
    grouped_phases = Phase.group_into_weeks(phases)
    grouped_phases.map.with_index(1) do |week_phases, index|
      week_phases_data(index, week_phases, learner_program_id)
    end
  end

  def week_phases_data(week, phases, learner_program_id)
    total_outputs = 0
    phases_data = []
    completed_outputs = 0
    phases.each do |phase|
      total = 0
      completed = completed_submissions(phase, learner_program_id)
      phase.assessments.includes(:submission_phases).where(
        requires_submission: true
      ).each do |assessment|
        if assessment.submission_phases.empty?
          total += 1
        end
        total += assessment.submission_phases.size
      end
      phases_data << phase_metrics(phase, completed, total)
      completed_outputs += completed
      total_outputs += total
    end
    {
      phases: phases_data,
      total: total_outputs,
      name: "Week " + week.to_s,
      completed: completed_outputs,
      percentage: get_percentage(completed_outputs, total_outputs)
    }
  end

  def get_percentage(completed, total)
    return 0 if total.zero?

    percentage = (completed / total.to_f) * 100
    percentage.nan? ? 0 : percentage.round
  end
end
