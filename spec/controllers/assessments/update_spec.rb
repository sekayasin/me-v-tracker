require "rails_helper"
require_relative "../../support/helpers/assessment_controller_helper.rb"

RSpec.describe AssessmentsController, type: :controller do
  let(:user) { create :user }
  let(:assessment) do
    Assessment.first
  end
  let(:framework_criterium) { create :framework_criterium }
  let(:json) { JSON.parse(response.body) }
  let(:metrics_attributes) { Hash.new }
  let!(:assessment_params) do
    attributes_for :assessment,
                   framework_criterium_id: framework_criterium.id
  end

  let(:invalid_assessment_params) do
    attributes_for(
      :assessment,
      framework_criterium_id: "Select Criterion",
      metrics_attributes: ""
    )
  end

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    allow(controller).to receive_message_chain("helpers.admin?").and_return true
  end

  describe "PUT #update" do
    context "when assessment update is successful" do
      it "returns success message" do
        put :update, params: {
          id: assessment.id,
          assessment: assessment_params
        }
        expect(Assessment.first.name).to eq assessment_params[:name]
        expect(Assessment.first.description).to eq(
          assessment_params[:description]
        )
        expect(Assessment.first.expectation).to eq(
          assessment_params[:expectation]
        )
        expect(
          Assessment.first.framework_criterium_id
        ).to eq(framework_criterium.id)
        expect(json["message"]).to eq("Learning outcome updated successfully")
      end
    end

    context "when criterium is not selected" do
      it "returns an error message" do
        put :update, params: {
          id: assessment.id,
          assessment: invalid_assessment_params
        }

        expect(json["error"]).to eq("Framework criterion is required")
      end
    end

    context "when an assessment is updated with an existing name" do
      it "returns an error object" do
        Assessment.last.update(name: "Kachi")
        assessment_params[:name] = "Kachi"
        put :update, params: {
          id: assessment.id,
          assessment: assessment_params
        }
        expect(json["error"]).to eq "Name has already been taken"
      end
    end
  end

  describe "PUT #update submission types" do
    include AssessmentControllerHelper
    before do
      @assessment = create(:assessment_with_phases)
    end

    context "when passed submission types" do
      let(:submission_types) do
        sub_types = build_list(:submission_phase, 4,
                               file_type: "link",
                               assessment: @assessment,
                               phase: @assessment.phases.first)
        transform(sub_types)
      end

      it "populates the db with submission types" do
        put :update, params: { id: @assessment.id,
                               assessment: {
                                 submission_types: submission_types
                               } }
        expect(json["message"]).to eq("Learning outcome updated successfully")
        expect(@assessment.submission_phases.length).to be >= 1
      end
    end

    context "assessment with multiple submission phases" do
      it "returns multiple phases after being updated" do
        assessment = create(:assessment_with_phases)
        create_list(:submission_phase, 4,
                    file_type: "link",
                    assessment: assessment,
                    phase: assessment.phases.first)

        get :fetch_submission_phases, params: {
          id: assessment.id,
          phaseId: assessment.phases.first.id
        }
        expect(json["is_multiple"]).to be(true)
        expect(json["submission_phases"].length).to be >= 1
      end
    end

    context "when created with update params" do
      it "deletes and updates specified submission phases" do
        assessment = create(:assessment_with_phases)
        create_list(:submission_phase, 4,
                    file_type: "link",
                    assessment: assessment,
                    phase: assessment.phases.first)
        put :update, params: { id: assessment.id,
                               assessment: {
                                 phases_to_be_deleted: [
                                   assessment.submission_phases.first.id
                                 ],
                                 phases_to_be_updated: [
                                   {
                                     assessment_id: assessment.id,
                                     phase_id: assessment.phases.first.id,
                                     day: 1,
                                     file_type: "file"
                                   }
                                 ]
                               } }
        expect(json["message"]).to eq("Learning outcome updated successfully")
      end
    end
  end
end
