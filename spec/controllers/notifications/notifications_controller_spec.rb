require "rails_helper"

RSpec.describe NotificationsController, type: :controller do
  let(:user) { create :user }
  let(:recipient_email) { "john.doe@andela.com" }
  let(:priority) { %w(Normal Urgent) }
  let(:content) { ["Hi there", "This is urgent"] }
  let(:is_read) { [false, true] }
  let(:group) { ["Assigned Learners"] }
  let(:params) do
    {
      recipient_emails: recipient_email,
      priority: priority[0],
      content: content[0],
      group: group[0]
    }
  end

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
  end

  describe "POST notification: #create" do
    it "saves notification and its attributes" do
      post  :create,
            params: params,
            xhr: true

      new_notification_message = NotificationsMessage.find(1)
      new_notification = Notification.find(1)
      expect(new_notification[:recipient_email]).to eq recipient_email
      expect(new_notification[:is_read]).to eq is_read[0]
      expect(new_notification_message[:content]).to eq content[0]
      expect(new_notification_message[:priority]).to eq priority[0]
      expect(new_notification_message.notification_group[:name]).to eq group[0]
    end

    it "creates notifications for each recipient with similar attributes" do
      params[:recipient_emails] = "john_doe@andela.con, foo_bar@andela.com"
      post  :create,
            params: params,
            xhr: true

      new_notification_message_count = NotificationsMessage.all.size
      new_notification_count = Notification.all.size

      expect(new_notification_count).to eq 2
      expect(new_notification_message_count).to eq 1
    end
  end

  describe "PUT notification: #update" do
    before do
      post :create, params: params, xhr: true
    end

    it "changes the state of the notification is_read attribute to true" do
      params[:notification_ids] = 4
      put :update,
          params: params,
          xhr: true

      archived_notification = Notification.find(4)

      expect(archived_notification[:is_read]).to eq is_read[1]
    end

    it "deletes the notification if is_read attribute is true" do
      params[:notification_ids] = 5
      put :update, params: params, xhr: true

      notice = Notification.find(5)

      put :update, params: params, xhr: true

      expect { notice.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
