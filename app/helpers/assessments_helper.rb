module AssessmentsHelper
  def get_assessment_details(assessments)
    assessment_metrics = []
    assessments.each do |assessment|
      assessment_metrics.push(
        assessment: assessment,
        metrics: filter_assessment_metrics(assessment),
        framework: assessment.framework.name,
        criteria: assessment.criterium.name,
        phases: assessment.phases.pluck(:id, :name, :phase_duration)
      )
    end
    assessment_metrics.uniq
  end

  def filter_assessment_metrics(assessment)
    filtered_metric = []
    assessment.metrics.each do |metric|
      filtered_metric.push(
        point: metric.point.value,
        description: metric.description
      )
    end
    filtered_metric
  end

  def assessments_details(program_id)
    if params[:framework_id].present?
      program_assessments = get_assessments_by_framework
    else
      program_assessments = Assessment.
                            get_assessments_by_program(program_id,
                                                       nil, pagination_query)
    end
    render json: {
      frameworks: Framework.get_program_frameworks(program_id),
      is_admin: helpers.admin?,
      criterium_frameworks: get_criteria_framework(
        Criterium.get_program_criteria_for_assessment(program_id)
      ),
      assessments: get_assessment_details(
        get_assessment_params(program_assessments)
      ),
      count: pagination_query[:count] ? program_assessments[:count] : nil
    }
  end

  def get_assessments_by_framework
    paginator = initialize_pagination
    query = build_assessment_query
    assessments_ids = ProgramsPhase.
                      includes(assessments: [:framework, :criterium,
                                             :phases, metrics: :point]).
                      where(query).pluck("assessments.id").uniq

    assessments = Assessment.
                  page(paginator.offset).
                  per(paginator.limit).
                  includes(:framework, :criterium,
                           :phases, metrics: :point).
                  where(id: assessments_ids)
    {
      assessments: assessments,
      count: pagination_query[:count] ? assessments.total_count : nil
    }
  end

  def all_assessments_details
    paginator = initialize_pagination
    assessments = Assessment.
                  page(paginator.offset).
                  per(paginator.limit).
                  includes(:framework, :criterium, metrics: :point).
                  all
    render json: {
      frameworks: Framework.all,
      is_admin: helpers.admin?,
      criterium_frameworks: get_criteria_framework(
        Criterium.order(:id).includes(:frameworks).all
      ),
      assessments: get_assessment_details(
        assessments
      ),
      count: pagination_query[:count] ? assessments.total_count : nil
    }
  end

  def build_assessment_query
    query = {}
    program_id = params[:program_id]
    framework_id = params[:framework_id]
    criterium_name = params[:criterium_name]
    if program_id.present? && program_id.to_i.positive?
      query[:program_id] = program_id.to_i
    end
    if framework_id.present? || criterium_name.present?
      query[:assessments] = {}
      framework_id.present? &&
        query[:assessments][:frameworks] = { id: framework_id.to_i }
      criterium_name.present? &&
        query[:assessments][:criteria] = { name: criterium_name }
    end
    query
  end

  private

  DEFAULT_OFFSET = 0
  DEFAULT_LIMIT = 10

  def initialize_pagination
    OpenStruct.new(offset: params[:offset].to_i || DEFAULT_OFFSET,
                   limit: params[:limit].to_i || DEFAULT_LIMIT)
  end

  def get_assessment_params(program_assessments)
    return program_assessments unless program_assessments.is_a?(Hash)
    if program_assessments[:assessments]
      return program_assessments[:assessments]
    end

    program_assessments
  end
end
