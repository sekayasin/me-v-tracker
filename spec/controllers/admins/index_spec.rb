require "rails_helper"

RSpec.describe AdminsController, type: :controller do
  let(:user) { create :user }

  let(:success_response) do
    stub_admin_data_success
    get :index
  end

  let(:error_response) do
    stub_admin_data_failure
    get :index
  end

  describe "GET #index" do
    before do
      stub_current_user(:user)
    end

    context "when request to get admin list is successful" do
      it "returns json data containing admin emails" do
        success_response

        expect(JSON.parse(success_response.body)).to include("emails")
      end
    end

    context "when request to get admin list fails" do
      it "returns json data containing the error message" do
        error_response

        expect(JSON.parse(error_response.body)).to include("error")
      end
    end
  end
end
