require "rails_helper"

RSpec.describe HolisticEvaluationsController, type: :controller do
  include_context "create evaluation context"
  include_context "eligibility context"

  let(:user) { create :user }

  before do
    stub_current_user :user
    allow(controller).to receive_message_chain(
      "helpers.user_is_lfa_or_admin?"
    ).and_return true
  end

  describe "POST #create" do
    context "when the user is not the Learner's LFA or an admin" do
      it "doesn't save score for the camper" do
        allow(controller).to receive_message_chain(
          "helpers.user_is_lfa_or_admin?"
        ).and_return false

        post  :create,
              params:
                {
                  id: learner_program.camper_id,
                  learner_program_id: learner_program.id,
                  holistic_evaluation: valid_scores
                },
              xhr: true

        expect(response.body).to eq ""
        expect(response).to have_http_status(401)
      end
    end

    context "when the user is the Learner's LFA or an Admin" do
      context "and user submits all scores as required" do
        it "saves holistic evaluation successfully" do
          post  :create,
                params:
                  {
                    id: learner_program.camper_id,
                    learner_program_id: learner_program.id,
                    holistic_evaluation: valid_scores
                  },
                xhr: true

          learner_evaluation =
            HolisticEvaluation.where(learner_program_id: learner_program.id)
          expect(learner_evaluation.count).to eq 1
          expect(learner_evaluation.first[:score]).to eq 2
          expect(flash[:notice]).to eq "evaluation-success"
        end
      end

      context "and user does not submit all scores" do
        it "flashes an error message" do
          post  :create,
                params:
                  {
                    id: learner_program.camper_id,
                    learner_program_id: learner_program.id,
                    holistic_evaluation: missing_scores
                  },
                xhr: true

          expect(flash[:error]).to eq "Score can't be blank"
        end
      end

      context "and Learner does not have the required number of holistic \
               evaluations" do
        it "saves score for the Learner" do
          post  :create,
                params:
                  {
                    id: learner_program.camper_id,
                    learner_program_id: learner_program.id,
                    holistic_evaluation: valid_scores
                  },
                xhr: true

          expect(flash[:notice]).to eq "evaluation-success"
        end
      end

      context "and Learner has the required number of holistic evaluations" do
        let!(:new_holistic_evaluations) do
          create_list(
            :holistic_evaluation,
            2,
            learner_program: learner_program,
            evaluation_average: evaluation_average
          )
        end

        it "doesn't save score for the learner" do
          post  :create,
                params:
                  {
                    id: learner_program.camper_id,
                    learner_program_id: learner_program.id,
                    holistic_evaluation: valid_scores
                  },
                xhr: true

          expect(response.body).to eq ""
          expect(response).to have_http_status(401)
        end
      end
    end
  end
end
