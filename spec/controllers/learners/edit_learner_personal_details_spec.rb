require "rails_helper"

RSpec.describe LearnersController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:bootcamper) { create :bootcamper_with_learner_program }

  before(:each) do
    bootcamper
    stub_current_user bootcamper
    session[:current_user_info] = bootcamper
  end

  describe "PUT #update_learner_personal_details" do
    context "when learner submits valid personal details" do
      it "updates learner personal details successfully" do
        put :update_learner_personal_details, params: {
          "username" => "vofedit",
          "phone_number" => "09021208953",
          "country" => "Nigeria",
          "city" => "Lagos"
        }

        learner = Bootcamper.find_by(camper_id: bootcamper[:camper_id])
        expect(learner.nil?).to eq(false)
        expect(learner[:username]).to eq("vofedit")
        expect(learner[:phone_number]).to eq("09021208953")
      end
    end
  end
end
