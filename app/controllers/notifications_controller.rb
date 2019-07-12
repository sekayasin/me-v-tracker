class NotificationsController < ApplicationController
  include NotificationsControllerHelper
  skip_before_action :redirect_non_andelan

  def create
    notification = create_notification notification_params

    if notification.is_a?(Array)
      render(
        json: { data: { message: "Notification(s) created" } },
        status: 201
      )
    else
      render notification[:validate]
    end
  end

  def update
    if validate_update(params).is_a?(Hash)
      return validate_update(params)
    end

    Notification.update_notifications params[:notification_ids]

    render json: { data: { message: "Notification(s) deleted" } }
  end

  private

  def notification_params
    params.permit(:content, :recipient_emails, :priority, :group)
  end
end
