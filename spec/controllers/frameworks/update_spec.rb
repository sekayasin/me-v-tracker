require "rails_helper"

RSpec.describe FrameworksController, type: :controller do
  let(:user) { create :user }
  let(:framework) do
    Framework.first
  end
  let(:json) { JSON.parse(response.body) }

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    allow(controller).to receive_message_chain("helpers.admin?").and_return true
  end

  describe "PUT #update" do
    context "when framework update is successful" do
      it "returns a success message" do
        put :update, params: {
          id: framework.id,
          framework: {
            description: "Newly edited description"
          }
        }

        expect(Framework.first.description).to eq("Newly edited description")
        expect(json["message"]).to eq("Framework updated successfully")
      end
    end

    context "when framework description is blank" do
      it "returns an error message" do
        post :update, params: {
          id: framework.id,
          framework: {
            description: ""
          }
        }

        expect(json["error"]).to eq("Framework description cannot be blank!")
      end
    end

    context "when specified framework does not exist" do
      it "returns an error message" do
        post :update, params: {
          id: "some-string",
          framework: {
            description: "Valid description"
          }
        }

        expect(json["error"]).to eq("Framework not found")
      end
    end
  end
end
