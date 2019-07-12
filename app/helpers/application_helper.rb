module ApplicationHelper
  def admin?
    email = session[:current_user_info][:email]

    if Rails.env == "production" && user_is_test_admin?(email)
      session[:current_user_info][:admin] = false
    end

    session[:current_user_info][:admin]
  end

  def creator?
    email = session[:current_user_info][:email]
    creator = Pitch.find_by(id: params["pitch_id"], created_by: email)
    creator.present?
  end

  def user_is_test_admin?(email)
    email == "test-user-admin@andela.com"
  end

  def action_buttons(edit_icon_class, edit_icon_id, delete_icon_class,
                     delete_icon_id)
    content_tag(:i, "edit",
                class: "material-icons icon-edit #{edit_icon_class}",
                id: edit_icon_id.to_s).
      concat content_tag(:i, "delete",
                         class: "material-icons icon-delete
                                 #{delete_icon_class}",
                         id: delete_icon_id.to_s)
  end

  def admin_actions(edit_icon_class = nil, edit_icon_id = nil,
                    delete_icon_class = nil, delete_icon_id = nil)
    if admin?
      content_tag(:td, class: "table-action") do
        content_tag(:span) do
          action_buttons(edit_icon_class, edit_icon_id,
                         delete_icon_class, delete_icon_id)
        end
      end
    end
  end

  def authorized_learner?
    session[:current_user_info][:learner] == true
  end

  def andelan_lfa?
    session[:current_user_info][:lfa] == true
  end

  def pitch_panelist?
    session[:current_user_info][:panelist]
  end

  def fetch_pitch_panellist
    Panelist.find_by(
      email: @user_email, pitch_id: params[:pitch_id]
    )
  end

  def set_status_color(status)
    "status-" + status.to_s.split(" ").join.downcase
  end

  def user_is_lfa?(camper_id)
    facilitator = Facilitator.find_by_email(
      session[:current_user_info][:email]
    )
    if facilitator.blank?
      return
    else
      facilitator_id = facilitator.id
      LearnerProgram.where(
        "camper_id = :camper_id AND
        (week_one_facilitator_id = :facilitator_id OR
          week_two_facilitator_id = :facilitator_id)",
        facilitator_id: facilitator_id,
        camper_id: camper_id
      ).present?
    end
  end

  def user_is_lfa_or_admin?(camper_id)
    user_is_lfa?(camper_id) || admin?
  end

  def set_metric_description(metric)
    metric_description = metric.description.split(" * ")[0]
    description_part = metric.description.split(" * ")[1]
    unless description_part.nil?
      metric_description = metric_description + "\n" + description_part
    end
    metric_description
  end

  def present(model, presenter_class = nil)
    presenter_class ||= "#{model.class}Presenter".constantize
    presenter = presenter_class.new model, self
    yield presenter if block_given?
  end

  def set_stubs(decision_or_lfa, data_group)
    stubs = { decision_one: "In Progress",
              decision_two: "Not Applicable",
              week_two_lfa: "Unassigned" }.freeze
    if decision_or_lfa.blank?
      stubs[data_group.to_sym]
    else
      decision_or_lfa
    end
  end

  def hide_header_footer?(*args)
    args.each do |url_path|
      return true if current_page?(url_path) ||
                     request.path.include?("respond")
    end
    false
  end
end
