class CriteriaController < ApplicationController
  include CriteriaControllerHelper

  before_action :admin?, only: %i[create update]
  before_action :set_criterium,
                except: %i[index
                           create
                           get_criteria
                           get_criteria_with_frameworks
                           get_framework_criterium_id]
  before_action :check_empty_metrics, only: %i[update]

  def create
    @criterium = Criterium.new(criterium_params)
    if has_frameworks?
      if @criterium.save
        set_frameworks
        flash[:notice] = "criterion-success"
      else
        flash[:error] = @criterium.errors.full_messages[0]
      end
    end
  end

  def destroy
    criteria = Criterium.find(params[:id])
    if criteria
      criteria.destroy
      render json: { message: "Criterion archived successfully",
                     id: params[:id], deleted: true }
    else
      render json: { error: "Criterion not found", deleted: false }
    end
  end

  def index
    @criteria = Criterium.all
  end

  def show
    render json: @criterium, include: { frameworks: { only: %i(name id) } }
  end

  def update
    if has_frameworks? && safe_frameworks?
      if @criterium.update(edit_criterium_params)
        cascade_criterium(params[:criterium][:metrics])
      else
        render json: { error: @criterium.reload.errors.full_messages[0] }
      end
    end
  end

  def cascade_criterium(metrics)
    @exists_error = safe_frameworks?
    response =
      if @exists_error.include? false
        { error: @exists_error[1] }
      else
        set_frameworks
        update_metrics(metrics)
        { message: "Criteria updated successfully" }
      end
    render json: response
  end

  def update_metrics(metrics)
    metrics.each do |key, value|
      @metric = Metric.where(criteria_id: @criterium.id, point_id: key.to_i)
      if @metric.exists?
        @metric.update(description: value)
      else
        Metric.create(description: value,
                      criteria_id: @criterium.id,
                      point_id: key.to_i)
      end
    end
  end

  def get_criteria_with_frameworks
    return criteria_search if params[:search]
    return criteria_with_frameworks if params[:program_id]

    all_criteria_with_frameworks
  end

  def get_criteria
    all_criteria = Criterium.get_criteria_for_program(
      params[:program_id]
    )

    criteria = all_criteria.select do |criterium|
      criterium["frameworks"][0]["id"] == params[:id].to_i
    end

    render json: criteria
  end

  def get_framework_criterium_id
    framework_criteria_id = FrameworkCriterium.find_by(
      criterium_id: params[:criterium_id],
      framework_id: params[:framework_id]
    ).id

    render json: framework_criteria_id
  end

  private

  def set_criterium
    @criterium = Criterium.includes(:frameworks).find(params[:id])
  end

  # Use strong params to get certain properties from criteria table
  def criterium_params
    params.require(:criterium).permit(:name, :description, :framework)
  end

  def edit_criterium_params
    params.require(:criterium).permit(:name,
                                      :description,
                                      :framework,
                                      :context)
  end

  def admin?
    redirect_to curriculum_path unless helpers.admin?
  end

  def check_empty_metrics
    result = check_empty(params[:criterium][:metrics])
    if result
      render json: { error: "Metrics cannot be empty" }
    else
      true
    end
  end
end
