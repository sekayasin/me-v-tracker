require "rails_helper"

RSpec.describe HolisticEvaluationsController, type: :controller do
  include_context "update evaluation context"
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

  before do
    post :create,
         params:
            {
              id: learner_program.camper_id,
              learner_program_id: learner_program.id,
              holistic_evaluation: valid_scores
            },
         xhr: true
  end

  describe "PUT #update" do
    context "if the user has not been the assigned Learner's LFA or an admin" do
      it "averts updates to the holistic score" do
        allow(controller).to receive_message_chain(
          "helpers.user_is_lfa_or_admin?" && "helpers.can_edit_scores?"
        ).and_return false

        put :update,
            params:
              {
                id: learner_program.camper_id,
                learner_program_id: learner_program.id,
                holistic_evaluation: valid_scores
              },
            xhr: true

        expect(response.body).to eq "{\"updated\":false}"
        expect(response).to have_http_status(401)
      end
    end

    context "if the user has not been the assigned Learner's LFA or an admin" do
      it "ensures the Database is not updated" do
        allow(controller).to receive_message_chain(
          "helpers.user_is_lfa_or_admin?" && "helpers.can_edit_scores?"
        ).and_return false

        expect do
          put :update,
              params:
                {
                  id: learner_program.camper_id,
                  learner_program_id: learner_program.id,
                  holistic_evaluation: valid_scores
                },
              xhr: true
        end.to_not(change { HolisticEvaluation.count })
      end
    end

    context "when the user has Admin access" do
      context "and the holistic evaluation scores are being submitted" do
        it "updates the learners scores" do
          allow(controller).to receive_message_chain(
            "helpers.can_edit_scores?"
          ).and_return true
          put :update,
              params:
              {
                id: learner_program.camper_id,
                learner_program_id: learner_program.id,
                holistic_evaluation: valid_scores
              },
              xhr: true

          learner_evaluation =
            HolisticEvaluation.where(learner_program_id: learner_program.id)
          expect(json["status"]).to be true
          expect(
            json["updated"]["0"]["score"].to_i
          ).to eq learner_evaluation[0].score
          expect(
            json["updated"]["0"]["comment"]
          ).to eq learner_evaluation[0].comment
        end
      end
    end

    context "when a user is not authorised to edit learner scores" do
      it "does not allow to edit the scores" do
        allow(controller).to receive_message_chain(
          "helpers.can_edit_scores?"
        ).and_return false
        put :update,
            params:
                {
                  id: learner_program.camper_id,
                  learner_program_id: learner_program.id,
                  holistic_evaluation: valid_scores
                },
            xhr: true
        expect(response).to have_http_status(401)
      end
    end
  end
end
