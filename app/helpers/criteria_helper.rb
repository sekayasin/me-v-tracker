module CriteriaHelper
  include CriteriaControllerHelper

  def get_criteria_with_frameworks
    return criteria_with_frameworks if params[:program_id]

    all_criteria_with_frameworks
  end
end
