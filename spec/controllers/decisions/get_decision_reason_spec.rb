require "rails_helper"

RSpec.describe DecisionsController, type: :controller do
  let(:user) { create :user }
  let(:learner_program) { create :learner_program }
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
  end

  after :all do
    Decision.delete_all
  end

  describe "GET #decision_reason" do
    context "when the decision status is 'Advanced' " do
      it "returns correct associated decision reasons" do
        get :get_decision_reason, params: {
          status: "Advanced"
        }

        expect(json.length).to eq(5)
      end
    end
  end
end
