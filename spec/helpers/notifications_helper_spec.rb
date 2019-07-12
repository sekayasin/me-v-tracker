require "rails_helper"

RSpec.describe NotificationsHelper, type: :helper do
  let(:user) { create :user }
  let!(:notification_group) { create(:notification_group) }
  let!(:notifications_message) do
    create(:notifications_message,
           notification_group_id: notification_group.id,
           priority: %w[Urgent Normal].sample)
  end
  let!(:recipient_email) { "rehema.wachira@andela.com" }
  let!(:first_notification) do
    Notification.create!(
      recipient_email: recipient_email,
      is_read: false,
      notifications_message_id: notifications_message.id
    )
  end
  let!(:second_notification) do
    Notification.create!(
      recipient_email: recipient_email,
      is_read: true,
      notifications_message_id: notifications_message.id
    )
  end

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
  end

  describe "current_user_notifications" do
    context "when a user has unread notification" do
      it "returns the unread notification" do
        unread = current_user_notifications[0][:results]

        expect(unread.size).to eq 1
      end
    end
    context "when a user has read notifications" do
      it "returns the read notification" do
        read = current_user_notifications[0][:is_read]

        expect(read.size).to eq 1
      end
    end
  end

  describe "get_notification_day_text" do
    it "returns a temporal noun based on a day" do
      unread = current_user_notifications[0][:results]
      unread_date = unread.first[1][0].created_at.localtime
      day = get_notification_day_text(unread_date)

      expect(day).to eql("Today, #{unread_date.strftime('%I:%M %p')}")
    end
  end
end
