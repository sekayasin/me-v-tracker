require "rails_helper"

RSpec.describe SurveysV2Controller, type: :controller do
  describe "GET #setup" do
    let(:user) { create :user }
    before do
      stub_current_user(:user)
      session[:current_user_info] = user.user_info
    end

    it "returns the index page" do
      get :index
      expect(response.body).to include("redirected")
      expect(response)
    end

    it "returns the setup page" do
      get :setup
      expect(response.body).to include("redirected")
    end
  end
end
