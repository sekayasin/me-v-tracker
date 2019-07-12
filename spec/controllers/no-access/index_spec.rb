require "rails_helper"

RSpec.describe NoAccessController, type: :controller do
  let(:user) { create :user }

  describe "GET #index" do
    it_behaves_like("response success", "get", :index)
  end
end
