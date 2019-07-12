require "rails_helper"

RSpec.describe HolisticEvaluationsController, type: :controller do
  include_context "create evaluation context"
  include_context "eligibility context"

  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user :user
    allow(controller).to receive_message_chain(
      "helpers.user_is_lfa_or_admin?"
    ).and_return true
  end

  describe "POST #create" do
    context "when a Learner has not been evaluated" do
      context "and a user submits a holistic evaluation" do
        it "the received number of evaluations of a learner is one" do
          post :create,
               params:
                 {
                   id: learner_program.camper_id,
                   learner_program_id: learner_program.id,
                   holistic_evaluation: valid_scores
                 },
               xhr: true

          expect(json["evaluations_received"]).to eq(1)
        end
      end
    end
  end
end
