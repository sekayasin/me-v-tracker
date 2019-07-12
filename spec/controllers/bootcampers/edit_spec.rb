require "rails_helper"

RSpec.describe LearnersController, type: :controller do
  let(:user) { create :user }
  let(:learner_program) { create :learner_program }
  let(:json) { JSON.parse(response.body) }

  let(:learner_info) do
    FactoryBot.get_test_user_details(bootcamper)
  end

  before do
    stub_current_user(:user)
  end

  after :all do
    LearnerProgram.delete_all
  end

  describe "#update_learner_information" do
    before do
      create(:center,
             name: learner_info[:learner_info][:city],
             country: learner_info[:learner_info][:country])
    end
    let(:bootcamper) { create :bootcamper_with_learner_program }
    let!(:response) do
      put :update_learner_information, params: learner_info
    end

    context "when request is valid" do
      it "updates a learner bio information" do
        expect(response.body).to include "testuser@email.com"
        expect(response.body).to include "Nigeria"
        expect(response.body).to include "Lagos"
        expect(response.body).to include "Female"
      end

      it "returns status code 200" do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "#get-learner-city" do
    let(:bootcamper) { create :bootcamper_with_learner_program }
    let!(:response) do
      get :get_learner_city,
          params: {
            country: learner_program.cycle_center.center.country,
            id: bootcamper.id,
            learner_program_id: learner_program.id
          }
    end

    context "when request is valid" do
      it "gets all cities belonging to that country" do
        expect(json.length).to eq 1
        expect(
          json.include?(learner_program.cycle_center.center.name)
        ).to be true
      end

      it "returns status code 200" do
        expect(response).to have_http_status(200)
      end
    end
  end
end
