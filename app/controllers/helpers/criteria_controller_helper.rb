module CriteriaControllerHelper
  def criteria_with_frameworks
    render json: {
      frameworks: Framework.get_program_frameworks(params[:program_id]).
        order(name: :desc),
      is_admin: helpers.admin?,
      criteria: Criterium.get_criteria_for_program(params[:program_id]),
      metrics: Criterium.get_criteria_metrics_in_program(params[:program_id]),
      points: Criterium.get_point_values_for_metrics(params[:program_id])
    }
  end

  def all_criteria_with_frameworks
    render json: {
      frameworks: Framework.all,
      is_admin: helpers.admin?,
      criteria: Criterium.all.
        as_json(include: { frameworks: { only: %i(name id) } })
    }
  end

  def has_frameworks?
    if params[:frameworks].nil?
      flash[:error] = "Please select a framework"
      return false
    end
    @framework_ids = params[:frameworks].map!(&:to_i)
    @removed_ids = @criterium.frameworks.map(&:id) - @framework_ids
    @new_ids = @framework_ids - @criterium.frameworks.map(&:id)
    true
  end

  def check_empty(object)
    result = false
    object.each do |key, value|
      if value.to_s.empty?
        result = true
        key
      end
    end
    result
  end

  def safe_frameworks?
    if removed_has_no_outputs?
      @success_message = "This framework can be safely updated"
      [true, @success_message]
    else
      @exists_error = "Some outputs will be affected by "\
        "removing that framework"
      [false, @exists_error]
    end
  end

  def removed_has_no_outputs?
    @removed_ids.none? do |id|
      Assessment.joins(:framework_criterium).where(
        framework_criteria: {
          framework_id: id,
          criterium_id: @criterium.id
        }
      ).count.positive?
    end
  end

  def set_frameworks
    remove_frameworks unless @removed_ids.empty?
    @new_ids.each do |id|
      FrameworkCriterium.find_or_create_by(
        framework_id: id,
        criterium_id: @criterium.id
      )
    end
    @criterium.frameworks.reload
  end

  def remove_frameworks
    @removed_ids.each do |id|
      FrameworkCriterium.where(
        framework_id: id,
        criterium_id: @criterium.id
      ).destroy_all
    end
  end

  def criteria_search
    render json: {
      criteria: Criterium.search(params[:search])
    }
  end
end
