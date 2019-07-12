class AdminsController < ApplicationController
  def index
    admins = AdminService.new.admin_data

    if admins["error"]
      render json: { error: admins["error"] }
    else
      render json: { emails: filter_emails(admins["values"]) }
    end
  end

  private

  def filter_emails(admin_list)
    admin_emails = []
    admin_list.each { |admin| admin_emails.push(admin["email"]) }

    admin_emails
  end
end
