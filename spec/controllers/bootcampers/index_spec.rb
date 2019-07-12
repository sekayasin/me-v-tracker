require "rails_helper"

RSpec.describe BootcampersController, type: :controller do
  let(:user) { create :user }

  before do
    stub_current_user(:user)
  end

  describe "GET #index" do
    context "when user" do
      before do
        allow(controller).to receive_message_chain(
          "helpers.admin?"
        ).and_return false
      end

      it "redirects" do
        get :index
        expect(response).to have_http_status 302
      end
    end
  end
end
