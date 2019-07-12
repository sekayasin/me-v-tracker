require "rails_helper"

RSpec.describe HolisticEvaluationsController, type: :controller do
  include_context "program criteria context"

  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user(:user)
    point = Point.first || create(:point, value: 0, context: "Just neutral")
    create(
      :metric,
      point: point,
      assessment: assessment,
      criteria_id: criterium.id
    )
  end

  after :all do
    Metric.delete_all
  end

  describe "GET #holistic_criteria_info" do
    context "when loading holistic criteria info with program id" do
      before do
        get :holistic_criteria_info, params: { program_id: program.id }
      end

      it "returns a json with a count of 2" do
        expect(json.count).to be == 2
      end

      it "returns json with criteria and metrics" do
        expect(json).to include "criteria"
        expect(json).to include "metrics"
      end
    end
  end
end
