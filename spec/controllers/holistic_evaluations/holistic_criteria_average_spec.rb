require "rails_helper"

RSpec.describe HolisticEvaluationsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:user) { create :user }
  let(:learner_program) { create :learner_program }
  let(:criterium) { create :criterium, name: "TIA" }

  let!(:holistic_evaluation) do
    create :holistic_evaluation,
           criterium: criterium,
           learner_program: learner_program
  end

  before do
    stub_current_user(:user)
    get :holistic_criteria_averages,
        params: { learner_program_id: learner_program.id }
  end

  describe "#holistic_criteria_averages" do
    it "returns success" do
      expect(response).to be_success
    end

    it "returns correct average score for TIA" do
      expect(json["TIA"]).to eq 1.0
    end
  end
end
