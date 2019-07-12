require "rails_helper"

RSpec.describe HolisticEvaluationsController, type: :controller do
  let(:user) { create :user }
  let(:criterium) { create :criterium }
  let(:learner_program) { create :learner_program }
  let(:evaluation_average) { create :evaluation_average }
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    @evaluation = create(
      :holistic_evaluation,
      score: 2,
      learner_program_id: learner_program.id,
      criterium_id: criterium.id,
      evaluation_average_id: evaluation_average.id
    )
  end

  after :all do
    HolisticEvaluation.delete_all
  end

  describe "GET #holistic_average" do
    context "when the learner does not have any evaluations" do
      it "returns false for can_edit_scores" do
        get :holistic_average, params: {
          learner_program_id: learner_program.id
        }
        expect(json["can_edit_scores"]).to be_falsey
      end
    end

    context "when the learner has evaluations" do
      it "gets correct holistic evaluation details" do
        get :holistic_average,
            params: { learner_program_id: learner_program.id }
        expect(json["holistic_evaluation_details"][0]["average"]).to eq(2)
        expect(
          json["holistic_evaluation_details"][0]["created_at"].length
        ).to eq(2)
        expect(
          json["holistic_evaluation_details"][0]["details"].length
        ).to eq(1)
      end
    end
  end
end
