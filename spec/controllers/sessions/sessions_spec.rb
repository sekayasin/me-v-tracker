require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  let(:user) { create :user }

  before do
    stub_current_user(:user)
  end
  describe "GET #login" do
    it "allows authenticated access" do
      get :login
      expect(response).to be_success
    end

    it "returns a 200 status" do
      expect(response).to have_http_status 200
    end

    it "assigns url to auth_url, forgot_url, oauth_url" do
      get :login
      expect(assigns[:oauth_url]).to be_truthy
      expect(assigns[:forgot_url]).to be_truthy
      expect(assigns[:login_url]).to be_truthy
    end

    it "redirects to the bootcamper page" do
      request.cookies["jwt-token"] = Faker::Crypto.md5
      get :login, params: {}, session: {
        current_user_info: {
          test: "test",
          andelan: true
        }
      }
      expect(response).to redirect_to(index_path)
    end
  end

  describe "GET #logout" do
    before(:each) do
      get :logout
    end
    it "redirects to the logout page" do
      expect(response).to redirect_to ENV["TEST_URL"]
    end

    it "has a response body" do
      expect(response.body).to eq "<html><body>You are being " \
                                  "<a href=\"#{ENV['TEST_URL']}\">" \
                                  "redirected</a>.</body></html>"
    end

    it "returns a 302 status" do
      expect(response).to have_http_status 302
    end

    it "reset cookie" do
      expect(request.cookies["jwt-token"]).to eq nil
    end

    it "reset session" do
      expect(session).to be_blank
    end
  end
end
