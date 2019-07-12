require "rails_helper"
RSpec.describe SupportController, type: :controller do
  let(:user) { create :user }
  let(:search_params) do
    { search: "" }
  end
  let(:search) do
    get :index, params: search_params, session: {
      current_user_info: {
        learner: false
      }
    }
  end

  describe "GET #index" do
    before do
      stub_current_user(:user)
    end

    context "when no search term is passed" do
      before do
        search
      end

      it "loads all faqs" do
        expect(assigns[:faqs].length).to eq 13
      end

      it "loads all resources" do
        expect(assigns[:resources].length).to eq 1
      end
    end

    context "when a search term is passed" do
      context "when the search term matches any faqs" do
        it "loads the matched faqs " do
          search_params[:search] = "ALC"
          search
          expect(assigns[:faqs].length).to eq 3
        end
      end

      context "when the search term does not match any faqs" do
        it "loads no faqs" do
          search_params[:search] = "Demarcation"
          search
          expect(assigns[:faqs].length).to eq 0
        end
      end
    end
  end
end
