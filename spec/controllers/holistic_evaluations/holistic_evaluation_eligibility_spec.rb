require "rails_helper"

RSpec.describe HolisticEvaluationsController, type: :controller do
  include_context "eligibility context"

  let(:user) { create :user }

  before do
    stub_current_user :user
    allow(controller).to receive_message_chain(
      "helpers.admin?",
      "helpers.user_is_lfa?"
    ).and_return true
  end

  describe "GET #eligibility" do
    context "when an admin or LFA has not reached the \
     max.no. of evaluations required" do
      it "permits the learner to have more evaluations" do
        get :eligibility,
            params:
              {
                learner_program_id: learner_program.id
              },
            xhr: true

        parsed_response = JSON.parse(response.body)
        expect(parsed_response["eligible"]).to eq true
      end
    end

    context "when an admin or LFA has reached the \
      max. no. of evaluations required" do
      let!(:new_holistic_evaluations) do
        create_list(
          :holistic_evaluation,
          2,
          learner_program: learner_program,
          evaluation_average: evaluation_average
        )
      end

      it "denies the learner from having more evaluations" do
        get :eligibility,
            params:
              {
                learner_program_id: learner_program.id
              },
            xhr: true

        parsed_response = JSON.parse(response.body)
        expect(parsed_response["eligible"]).to eq false
      end
    end
  end
end
