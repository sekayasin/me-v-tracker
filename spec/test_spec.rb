require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  describe "GET #login" do
    it "responds successfully with an HTTP 200 status code" do
      get :login
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the login template" do
      get :login
      expect(response).to render_template("login")
    end
  end
end
