module NotificationsControllerHelper
  def validate_create(params)
    params_message = {
      content: "Content is required",
      group: "Group is required",
      recipient_emails: "Recipient email is required"
    }

    invalid_params = params_message.select { |param| params[param].blank? }

    unless invalid_params.empty?
      return {
        json: { data: { message: invalid_params.values } },
        status: 400
      }
    end

    true
  end

  def validate_update(params)
    if params[:notification_ids].blank?
      return {
        json: { data: { message: "Notification not found" } },
        status: 404
      }
    end

    true
  end
end
