require "rails_helper"

RSpec.describe Notification, type: :model do
  let!(:notification_group) { create(:notification_group) }
  let!(:notifications_message) do
    create(:notifications_message,
           notification_group_id: notification_group.id,
           priority: %w[Urgent Normal].sample)
  end
  let!(:recipient_email) { "rehema.wachira@andela.com" }
  let!(:notification1) do
    Notification.create!(
      recipient_email: recipient_email,
      is_read: false,
      notifications_message_id: notifications_message.id
    )
  end
  let!(:notification2) do
    Notification.create!(
      recipient_email: recipient_email,
      is_read: true,
      notifications_message_id: notifications_message.id
    )
  end

  context "when validating associations" do
    it "belongs to notifications_message" do
      is_expected.to belong_to(:notifications_message)
    end
  end

  describe "get_notifications" do
    context "when is_read is false" do
      it "returns notifications that are unread" do
        unread = Notification.get_notifications(recipient_email, false)
        unread.each_value do |value|
          expect(value[0][:is_read]).to eq false
        end

        expect(unread.size).to eq 1
      end
    end

    context "when is_read is true" do
      it "returns notifications that are read" do
        read = Notification.get_notifications(recipient_email, true)

        read.each_value do |value|
          expect(value[0][:is_read]).to eq true
          expect(value[0][:recipient_email]).to eq recipient_email
        end

        expect(read.size).to eq 1
      end
    end
  end

  describe "update_notifications" do
    it "returns an is_read value of true" do
      Notification.update_notifications(notification1[:id])

      expect(notification1.reload.is_read).to eq(true)
    end
  end
end
