require "rails_helper"

RSpec.describe LearnersController, type: :controller do
  let(:user) { create :user }
  let(:bootcamper) { create :bootcamper_with_learner_program }
  let(:json) { JSON.parse(response.body) }
  let(:valid_technical_details_params) do
    {
      preferred_languages_stacks: [1, 2, 3]
    }
  end

  let(:invalid_technical_details_params) do
    {
      preferred_languages_stacks: ["invalid"]
    }
  end

  before do
    stub_current_user :user
    bootcamper
    session[:current_user_info] = bootcamper
  end

  describe "GET #get_learner_technical_details" do
    context "when learner has been enrolled to a program" do
      it "returns learner technical details" do
        get :get_learner_technical_details, format: :json

        expect(json.length).to eq(2)
      end
    end
  end

  describe "PUT #update_learner_technical_details" do
    context "when learner submits valid technical details" do
      it "updates learner technical details successfully" do
        put :update_learner_technical_details, params: {
          details: valid_technical_details_params
        }

        expect(BootcampersLanguageStack.first.language_stack_id).to eq(1)
        expect(BootcampersLanguageStack.first.camper_id).to eq(bootcamper.id)
        expect(json["message"]).to eq(
          "Learner technical details updated successfully"
        )
      end
    end

    context "when learner submits invalid technical details" do
      it "returns an error for unsuccessful update" do
        put :update_learner_technical_details, params: {
          details: invalid_technical_details_params
        }

        expect(json["message"]).to eq(
          "Learner technical details update unsuccessful"
        )
      end
    end
  end
end
