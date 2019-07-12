class AssessmentFacade
  include AssessmentReport
  include ProgressReport

  def initialize(params = nil)
    @id_params = params[:learner_program_id]
    program_id = LearnerProgram.find(@id_params).program_id
    @program_phases = ProgramsPhase.where(program_id: program_id).includes(
      :phase, assessments: :framework_criterium
    )

    completed_assessments
  end

  def completed_assessments
    @bootcamper_assessments = Score.get_bootcamper_scores(@id_params)
    @completed_assessments = {}

    @program_phases.each do |program_phase|
      @completed_assessments[program_phase.phase.id] = {}
      grouped_assessments = group_assessments_by_framework(program_phase.
        assessments)

      grouped_assessments.each do |framework, assessments|
        @completed_assessments[program_phase.phase.id][framework] = {}
        set_assessed_scores(program_phase.phase, framework, assessments)
      end
    end

    set_total_assessed
    @completed_assessments
  end

  def set_assessed_scores(phase, framework, assessments)
    group_assessments_by_criterium(assessments).each_key do |criterium|
      @completed_assessments[phase.id][framework][criterium] = {}
    end

    @bootcamper_assessments.each do |scored|
      next unless scored.phase_id == phase.id

      filtered = filter_assessments(assessments, scored)

      filtered.each do |filtered_assessment|
        score = [scored.score, scored.comments, scored.updated_at.utc.to_s]
        id = filtered_assessment.id
        criterium = filtered_assessment.framework_criterium.criterium.name
        @completed_assessments[phase.id][framework][criterium][id] = score
      end
    end
    set_completed_by_framework(phase, framework, assessments.count)
  end

  def set_completed_by_framework(phase, framework, assessments_count)
    count = 0
    @completed_assessments[phase.id][framework].each_value do |assessments|
      count += assessments.count
    end

    completed = count == assessments_count
    @completed_assessments[phase.id][framework][:completed] = completed
  end

  def filter_assessments(assessments, scored)
    assessments.select do |assessment|
      assessment.id == scored.assessment_id
    end
  end

  def set_total_assessed
    completed_in_program = completed_assessments_per_program(
      @id_params
    )

    @program_phases.each do |program_phase|
      grouped_assessments = group_assessments_by_framework(program_phase.
        assessments)
      completed = get_completed_status(program_phase.phase, grouped_assessments)
      @completed_assessments[program_phase.phase.id][:completed] = completed
    end

    @completed_assessments[:assessment] = completed_in_program
  end

  def get_completed_status(phase, assessments)
    assessment_count = 0
    assessed_count = 0

    assessments.each do |framework, grouped_assessments|
      grouped_by_criteria = group_assessments_by_criterium(grouped_assessments)
      grouped_by_criteria.each do |criteria, assessments_by_criteria|
        assessed_count +=
          @completed_assessments[phase.id][framework][criteria].count
        assessment_count += assessments_by_criteria.count
      end
    end

    assessment_count == assessed_count
  end
end
