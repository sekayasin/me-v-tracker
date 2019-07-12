require "rails_helper"

RSpec.describe DecisionsController, type: :controller do
  let(:user) { create :user }
  let(:learner_program) do
    create :learner_program,
           decision_one: "Advanced",
           decision_two: "In Progress"
  end
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    allow(controller).to receive_message_chain("helpers.admin?").and_return true

    @decision = {
      learner_program_id: learner_program.id,
      stage: 1,
      reasons: [
        "Output Quality - Technical Skills",
        "Output Quality - Team Skills"
      ],
      comment: "This is a valid comment"
    }
  end

  after :all do
    Decision.delete_all
  end

  describe "POST #save_decision" do
    context "when decision details is provided for a learner " do
      it "saves the correct decision detail" do
        post :save_decision, params: {
          decisions: @decision
        }

        expect(json["message"]).to eq("Decision updated successfully")
      end
    end
  end
end
