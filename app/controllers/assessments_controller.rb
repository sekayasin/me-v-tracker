class AssessmentsController < ApplicationController
  before_action :admin?, only: %i[create update]
  skip_before_action(
    :redirect_non_andelan,
    only: %i[
      get_phase_assessments
      submit_assessment_output
      update_assessment_output
      fetch_submission_phases
    ]
  )
  before_action :get_assessment, only: %i[show update fetch_submission_phases]
  include AssessmentReport
  include AssessmentsHelper
  include AssessmentsControllerHelper

  def all
    phase = Phase.includes(
      assessments: [framework_criterium: :framework]
    ).find_by(id: params[:id])

    return record_not_found if phase.nil?

    grouped_assessments = {}

    group_assessments_by_framework(phase.assessments).
      each do |framework, assessments|
      grouped_assessments[framework] =
        group_assessments_by_criterium(assessments)
    end

    render json: grouped_assessments
  end

  def create
    @assessment = Assessment.new(assessment_params)
    if @assessment.save
      flash[:notice] = "assessment-success"
    else
      error = @assessment.errors.full_messages[0]
      flash[:error] = if error == "Framework criterium can't be blank"
                        "Framework or Criterion cannot be blank"
                      else
                        error
                      end
    end
  end

  def show
    render json: {
      id: @unique_assessment.id,
      name: @unique_assessment.name,
      expectation: @unique_assessment.expectation,
      context: @unique_assessment.context,
      description: @unique_assessment.description,
      requires_submission: @unique_assessment.requires_submission,
      submission_types: @unique_assessment.submission_types,
      framework_id: @unique_assessment.framework_criterium.framework_id,
      framework_name: @unique_assessment.framework_criterium.framework.name,
      criterium_id: @unique_assessment.framework_criterium.criterium_id,
      criteria_name: @unique_assessment.framework_criterium.criterium.name,
      framework_criterium_id: @unique_assessment.framework_criterium_id,
      metrics: @unique_assessment.metrics.order(:point_id),
      duration: [@unique_assessment.duration(params[:programId])],
      submission_phases: @unique_assessment.submission_phases
    }
  end

  def update
    populate_submission_types
    update_and_delete_submission_phases
    response =
      if params[:assessment][:framework_criterium_id] == "Select Criterion"
        { error: "Framework criterion is required" }
      elsif @unique_assessment.update(assessment_params)
        { message: "Learning outcome updated successfully" }
      else
        { error: @unique_assessment.reload.errors.full_messages[0] }
      end

    render json: response
  end

  def destroy
    assessment = Assessment.find(params[:id])
    assessment.destroy
    render json: { message: "Learning Outcome has been archived successfully",
                   id: params[:id], archived: true }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Learning Outcome not found", archived: false }
  end

  def fetch_submission_phases
    render json: {
      submission_types: @unique_assessment.submission_types,
      submission_phases: present_phases,
      is_multiple: !@submissions_per_day.empty?
    }
  end

  def get_completed_assessments
    assessments = AssessmentFacade.new(params)
    render json: assessments.completed_assessments
  end

  def get_assessment_metrics
    metrics = Metric.where(assessment_id: params[:assessment_id])
    render json: metrics if metrics
  end

  def submit_assessment_output
    @learner_program = get_learner_program
    file_name_id = generate_id
    if verify_submission_file(params[:submission_file])
      file_link = get_learner_uploaded_file(
        params[:submission_file], file_name_id
      )
      file_name = params[:submission_file].original_filename
    end
    if @learner_program.ongoing?
      if submission_has_been_provided(params[:phase_id],
                                      params[:assessment_id],
                                      params[:submission_phase_id])
        return render json: { saved: false, errors: { submission: [
          "for this output has already been provided"
        ] } }
      end
      @output = add_learner_output(file_link, file_name, params)
      render json: get_output_submission_response
    else
      render json: { saved: false, errors: { submission: [
        "is not allowed for completed cycle"
      ] } }
    end
  end

  def update_assessment_output
    @learner_program = get_learner_program
    file_name_id = generate_id
    if verify_submission_file(params[:submission_file])
      file_link =
        update_uploaded_file(
          params[:output_id],
          params[:submission_file],
          file_name_id
        )
      file_name = params[:submission_file].original_filename
    end
    if @learner_program.ongoing?
      @output = update_learner_output(file_link, file_name, params)
      render json: get_output_submission_response
    else
      render json: { saved: false, errors: { submission: [
        "is not allowed for completed cycle"
      ] } }
    end
  end

  private

  def admin?
    redirect_to content_management_path unless helpers.admin?
  end

  def get_assessment
    @unique_assessment = Assessment.find(params[:id])
  end

  def assessment_params
    params.require(:assessment).
      permit(
        :name,
        :description,
        :expectation,
        :framework_criterium_id,
        :requires_submission,
        :context,
        metrics_attributes: %i(description point_id)
      ).
      tap do |whitelisted|
      whitelisted[:submission_types] = params[:assessment][:submission_types]
    end
  end
end
