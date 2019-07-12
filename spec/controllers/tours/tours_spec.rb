require "rails_helper"

RSpec.describe ToursController, type: :controller do
  let(:tour_page) { "learners" }
  let(:admin) { create(:user, :admin) }
  let(:lfa) { create(:user, :facilitator) }
  let(:non_lfa) { create(:user) }
  let(:bootcamper) { create(:bootcamper) }
  let(:json) { JSON.parse(response.body) }

  def stub_user(user)
    stub_current_user(user)
    session[:current_user_info] = user.user_info
  end

  def post_tour_as(user, page)
    stub_user user
    post :create, params: { page: page }
    expect(response.status).to eq(201)
  end

  describe "GET user_status" do
    xcontext "As an admin first visit" do
      before { stub_user admin }

      it "gets false user status" do
        get :user_status, params: { page: tour_page }
        expect(response.status).to eq 200
        expect(json["has_toured"]).to eq false
      end
    end

    context "As an admin second visit" do
      before do
        tour = Tour.create(
          name: "learners"
        )
        TouristTour.create(
          tourist_email: admin.user_info[:email],
          tour_id: tour.id,
          role: "Admin"
        )
        stub_user admin
      end

      after do
        TouristTour.destroy_all
        Tour.destroy_all
      end

      it "gets true user status" do
        get :user_status, params: { page: tour_page }
        expect(response.status).to eq 200
        expect(json["has_toured"]).to eq true
      end
    end
  end

  describe "POST create" do
    context "As an admin" do
      before { post_tour_as admin, tour_page }

      it "create a tour entry" do
        expect(json["tourist_tour"]["role"]).to eq "Admin"
      end
    end

    context "As an LFA" do
      before {  post_tour_as lfa, tour_page }

      it "create a tour entry" do
        expect(json["tourist_tour"]["role"]).to eq "LFA"
      end
    end

    context "As an Andelan Non-LFA" do
      before {  post_tour_as non_lfa, tour_page }

      it "create a tour entry" do
        expect(json["tourist_tour"]["role"]).to eq "Non-LFA"
      end
    end

    context "As a Learner " do
      before do
        stub_current_user bootcamper
        session[:current_user_info] = {
          **non_lfa.user_info,
          andelan: false,
          learner: true
        }
      end

      it "create a tour entry" do
        post :create, params: { page: tour_page }
        expect(response.status).to eq(201)
        expect(json["tourist_tour"]["role"]).to eq "Learner"
      end
    end
  end
end
