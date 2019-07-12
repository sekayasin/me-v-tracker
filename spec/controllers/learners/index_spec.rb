require "rails_helper"

RSpec.describe LearnersController, type: :controller do
  let(:user) { create :user }
  let(:bootcamper) { create :bootcamper_with_learner_program }

  describe "GET #index" do
    before do
      stub_current_user :user
      bootcamper
      session[:current_user_info] = bootcamper

      get :index
    end

    it "renders index template" do
      expect(response).to render_template(:index)
      expect(response).to have_http_status 200
    end

    it "sets @personal_info hash" do
      expect(assigns(:personal_info).nil?).to eq(false)
    end

    it "sets the right hash keys" do
      expect(assigns(:personal_info).keys).to include(
        :name, :email, :about, :gender, :phone_number, :location, :links
      )
    end
  end
end
