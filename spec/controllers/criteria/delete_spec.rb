require "rails_helper"

RSpec.describe CriteriaController, type: :controller do
  let(:user) { create :user }
  before do
    @criterion = create :criterium
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    allow(controller).to receive_message_chain("helpers.admin?").and_return true
  end
  describe "DELETE #destroy" do
    context "when criterion archiving is successful" do
      it "returns success message" do
        delete :destroy, params: {
          id: @criterion.id
        }
        json = JSON.parse(response.body)
        expect(json["message"]).
          to eq("Criterion archived successfully")
      end
    end
  end
end
