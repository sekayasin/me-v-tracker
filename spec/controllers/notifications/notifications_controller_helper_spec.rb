require "rails_helper"

RSpec.describe NotificationsControllerHelper, type: :helper do
  let(:recipient_email) { "john.doe@andela.com" }
  let(:priority) { %w(Urgent Normal) }
  let(:content) { [" ", "This is urgent"] }
  let(:is_read) { [false, true] }
  let(:group) { "Assigned Learners" }
  let(:params) do
    {
      recipient_emails: recipient_email,
      priority: priority[0],
      content: content[0],
      group: group
    }
  end

  describe "notifications controller helper '.valid?'" do
    context "when an update action is taken" do
      context "when notification ID(s) is/are not provided" do
        it "responds with an error status and cancels the update" do
          params[:notification_ids] = " " || [] || {}
          is_valid_response = validate_update(params)

          expect(is_valid_response[:json][:data][:message]).
            to eq "Notification not found"
          expect(is_valid_response[:status]).to eq 404
        end
      end

      context "when notification ID(s) is/are provided" do
        it "returns true and make the update" do
          params[:notification_ids] = [1, 2]
          is_valid_response = validate_update(params)

          expect(is_valid_response).to eq true
        end
      end
    end

    context "when a notification creation action is taken" do
      context "when content is not provided" do
        it "returns false and does not create the notification" do
          is_valid_response = validate_create(params)

          expect(is_valid_response[:json][:data][:message][0]).
            to eq "Content is required"
          expect(is_valid_response[:status]).to eq 400
        end
      end

      context "when group is not provided" do
        it "returns false and does not create the notification" do
          params[:content] = content[1]
          params[:group] = ""

          is_valid_response = validate_create(params)

          expect(is_valid_response[:json][:data][:message][0]).
            to eq "Group is required"
          expect(is_valid_response[:status]).to eq 400
        end
      end

      context "when recipient_emails is/are not provided" do
        it "returns false and does not create the notification" do
          params[:content] = content[1]
          params[:recipient_emails] = []

          is_valid_response = validate_create(params)

          expect(is_valid_response[:json][:data][:message][0]).
            to eq "Recipient email is required"
          expect(is_valid_response[:status]).to eq 400
        end
      end

      context "when content, group is not provided" do
        it "returns false and does not create the notification" do
          params[:content] = content[0]
          params[:group] = ""

          is_valid_response = validate_create(params)

          expect(is_valid_response[:json][:data][:message][0]).
            to eq "Content is required"
          expect(is_valid_response[:json][:data][:message][1]).
            to eq "Group is required"
          expect(is_valid_response[:status]).to eq 400
        end
      end

      context "when content, group and recipient_email params are provided" do
        it "returns true and creates the notification" do
          params[:content] = content[1]
          validate_create(params)

          expect(validate_create(params)).to eq true
        end
      end
    end
  end
end
