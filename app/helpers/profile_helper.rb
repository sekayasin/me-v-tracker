module ProfileHelper
  include ApplicationHelper
  def display_lfa_details(email)
    if email.nil?
      content_tag(:div, content_tag(:p, "No LFA assigned yet"))
    else
      name = email.split("@")[0].split(".").each(&:capitalize!).join(" ")
      content_tag(:div) do
        concat(content_tag(:span, content_tag(:span, name)))
        concat(content_tag(:p, content_tag(:span, format_text(email))))
      end
    end
  end

  def can_edit_scores?(camper_id, cycle_centre_id)
    return CycleCenter.active_for_admin?(cycle_centre_id) if admin?

    user_is_lfa?(camper_id) && CycleCenter.active_for_admin?(cycle_centre_id)
  end

  def yield_active_phase(key, phase)
    if key == "title"
      phase.empty? ? "" : phase.values.last[:title]
    else
      phase.empty? ? [] : phase.values.map { |target| target[:index] || 0 }
    end
  end

  private

  def format_text(text)
    if text.downcase.include? "unassigned"
      text = "-"
    end
    text
  end
end
