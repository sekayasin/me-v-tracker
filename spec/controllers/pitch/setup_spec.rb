require "rails_helper"

RSpec.describe PitchController, type: :controller do
  describe "GET #pitch_setup and #index" do
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
      get :pitch_setup
      expect(response.body).to include("redirected")
    end
  end
end
