require "rails_helper"

RSpec.describe AssessmentsController, type: :controller do
  include_context "assessment context"

  before do
    stub_current_user(:user)
    allow(controller).to receive(:admin?)
  end

  describe "POST #create" do
    context "when appropriate parameters are passed" do
      let(:request) do
        post :create,
             params: { assessment: assessment_params },
             xhr: true
      end

      it "creates a new output" do
        expect { request }.to change(Assessment, :count).by(1)
      end

      it "creates four new metrics" do
        expect { request }.to change(Metric, :count).by(4)
      end

      it "displays a successful flash message" do
        request
        expect(flash[:notice]).to eq "assessment-success"
      end
    end

    context "when some parameters are missing" do
      let(:bad_request) do
        post :create, params: { assessment: attributes_for(
          :assessment,
          framework_criterium_id: "",
          metrics_attributes: ""
        ) },
                      xhr: true
      end

      it "does not create a new output" do
        expect { bad_request }.not_to change(Assessment, :count)
      end

      it "does not create any metrics" do
        expect { bad_request }.not_to change(Metric, :count)
      end
    end

    context "when an assessment name already exists" do
      it "displays an appropriate flash message" do
        2.times do
          post :create,
               params: { assessment: assessment_params },
               xhr: true
        end
        expect(flash[:error]).to eq "Name has already been taken"
      end
    end

    context "when a non-admin attempts to create an output" do
      it_behaves_like "prevent non admins from performing CRUD"
    end
  end
end
