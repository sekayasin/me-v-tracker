module HolisticPerformanceHistoryHelper
  include ApplicationHelper
  def can_edit_scores?(camper_id, cycle_centre_id)
    return CycleCenter.active_for_admin?(cycle_centre_id) if admin?

    user_is_lfa?(camper_id) && CycleCenter.active_for_admin?(cycle_centre_id)
  end
end
