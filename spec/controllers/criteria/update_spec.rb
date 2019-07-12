require "rails_helper"

RSpec.describe CriteriaController, type: :controller do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  let(:params) do
    {
      "criterium" =>
      {
        "name" => "AWEDFCAS",
        "description" => "Description.",
        "context" => "AWEDFCAS",
        "metrics" =>
        {
          "5" => "AWEDFCAS",
          "6" => "AWEDFCAS",
          "7" => "AWEDFCAS",
          "8" => "AWEDFCAS",
          "9" => "AWEDFĆAS"
        }
      },
      "frameworks" => ["1"],
      "id" => 1
    }
  end

  before do
    stub_current_user(:user)
    controller.stub(:admin?)
    criteria_points = {
      very_satisfied: 2,
      satisfied: 1,
      neutral: 0,
      unsatisfied: -1,
      very_unsatisfied: -2
    }

    criteria_points.each do |context, value|
      Point.create(context: context.to_s.titleize, value: value)
    end
  end

  describe "PUT #update" do
    context "when criterion updates successfully" do
      it "creates a new criterion" do
        put :update,
            params: params,
            xhr: true
        expect(json["message"]).to eq("Criteria updated successfully")
      end
    end

    context "when criterion updates with an error" do
      it "throws error on update criterion" do
        params["criterium"]["metrics"]. \
          update(params["criterium"]["metrics"]) { |_key, _value| "" }
        put :update,
            params: params,
            xhr: true
        expect(json["error"]).to eq("Metrics cannot be empty")
      end
    end
  end
end
