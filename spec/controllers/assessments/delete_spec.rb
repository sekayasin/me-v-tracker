require "rails_helper"

RSpec.describe AssessmentsController, type: :controller do
  let(:user) { create :user }

  before do
    @assessment = create :assessment
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    allow(controller).to receive_message_chain("helpers.admin?").and_return true
  end

  describe "DELETE #destroy" do
    context "when assessment archiving is successful" do
      it "returns success message" do
        delete :destroy, params: {
          id: @assessment.id
        }
        json = JSON.parse(response.body)
        expect(json["message"]).
          to eq("Learning Outcome has been archived successfully")
      end
    end

    context "when assessment archiving is unsuccessful" do
      before do
        assessment = Assessment.find(@assessment.id)
        assessment.destroy
      end
      it "returns error message" do
        delete :destroy, params: {
          id: @assessment.id
        }
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Learning Outcome not found")
      end
    end
  end
end
