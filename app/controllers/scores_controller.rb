class ScoresController < ApplicationController
  include ProgressReport
  include ScoresControllerHelper
  before_action :redirect_non_admin_andelan

  def create
    learner = params[:learner_program_id]
    scores = params[:scores]
    return unless helpers.admin? || helpers.user_is_lfa?(params[:id])
    return if blank_score_params?(scores)

    @unsaved_scores = []
    params[:scores].each do |score|
      unless Score.save_score(score_params(score), learner)
        @unsaved_scores << score[:assessment_id].to_i
      end
    end

    set_camper_progress(learner.to_i)
    @unsaved_scores.empty? ? flash[:notice] = "score-success" : @unsaved_scores
  end

  def new
    @statuses = get_statuses
    learner_program = LearnerProgram.find(params[:learner_program_id]).program
    program_id = learner_program.id
    @criteria = Criterium.get_program_criteria(program_id)
    fields = %w(id name phase_duration)
    @phases = Program.find(program_id).phases.pluck(*fields)
    @learner_details = get_learner_progress(params[:learner_program_id])
    @countries = Center.get_all_countries
    @current_phase = get_current_phase(@learner_details, @phases, nil)
    respond_to do |format|
      format.js { render file: "profile/profile.js.erb" }
      format.html { render template: "profile/profile" }
      format.json { render json: verified_outputs(program_id) }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to not_found_path
  end

  def get_statuses
    statuses = RedisService.get("learnerspage:statuses")
    unless statuses
      statuses = DecisionStatus.get_all_statuses
      RedisService.set("learnerspage:statuses", statuses)
    end
    statuses
  end

  private

  def verified_outputs(program_id)
    begin
      assessments_count = total_assessments(program_id)
    rescue ActiveRecord::RecordNotFound
      assessments_count = 0
    end
    {
      'verified_assessments': Score.total_assessed(params[:learner_program_id]),
      'assessments_count': assessments_count
    }.to_json
  end

  def blank_score_params?(scores)
    scores.any? { |score| score[:score] == "" || score[:comments] == "" }
  end

  def score_params(score)
    score.permit(
      :score,
      :comments,
      :assessment_id,
      :phase_id,
      :original_updated_at
    )
  end
end
