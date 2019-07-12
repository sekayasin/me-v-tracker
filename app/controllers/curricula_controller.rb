class CurriculaController < ApplicationController
  include FrameworksHelper
  include CriteriaHelper
  include AssessmentsHelper

  before_action :admin?, only: %i[create update]

  def index
    @frameworks = RedisService.get("curricula_page:frameworks")
    unless @frameworks
      @frameworks = Framework.order(name: :desc).all.pluck(:id, :name)
      RedisService.set("curricula_page:frameworks", @frameworks)
    end
    @total_assessments = RedisService.get("curricula_page:total_assesments")
    unless @total_assessments
      @total_assessments = Assessment.all.size
      RedisService.set("curricula_page:total_assesments", @total_assessments)
    end
    @assessment = Assessment.new
    Point.all.limit(4).each { |point| @assessment.metrics.build(point: point) }
  end

  def get_curriculum_details
    if params[:search]
      search_curriculum = RedisService.get(
        "curricula_page:search_curriculum_#{params}"
      )
      unless search_curriculum
        return get_search_curriculum
      end

      render json: search_curriculum
    else
      criteria_with_frameworks = RedisService.get(
        "curricula_page:criteria_frameworks_#{params}"
      )
      unless criteria_with_frameworks
        return get_framework_criteria
      end

      render json: criteria_with_frameworks
    end
  end

  def curriculum_search
    render json: {
      criteria: Criterium.search(params[:search], params[:program_id]),
      assessment: include_admin_status(
        get_assessment_details(
          Assessment.get_assessments_by_program(
            params[:program_id],
            params[:search]
          )
        )
      ),
      metrics: Metric.all.as_json,
      points: Point.all.as_json
    }
  end

  def include_admin_status(all_assessments)
    all_assessments.each do |assessment|
      assessment[:isAdmin] = helpers.admin?
    end
  end

  private

  def admin?
    redirect_to curriculum_path unless helpers.admin?
  end

  def get_search_curriculum
    search_curriculum = curriculum_search
    RedisService.set(
      "curricula_page:search_curriculum_#{params}",
      search_curriculum
    )
    search_curriculum
  end

  def get_framework_criteria
    criteria_with_frameworks = get_criteria_with_frameworks
    RedisService.set(
      "curricula_page:criteria_frameworks_#{params}", criteria_with_frameworks
    )
    criteria_with_frameworks
  end
end
