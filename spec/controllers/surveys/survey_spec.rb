require "rails_helper"

RSpec.describe SurveysController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:user) { create :user }
  let(:survey) { create :survey }
  before do
    stub_current_user(:user)
    @program = Program.first
    @cycle_center1 = create(:cycle_center, program_id: @program.id)
    @cycle_center2 = create(:cycle_center, program_id: @program.id)
  end
  describe "POST #create" do
    context "when admin creates survey with valid payload" do
      before do
        post :create,
             params: {
               survey: build(:survey).attributes,
               recipients: [
                 @cycle_center1.cycle_center_id,
                 @cycle_center2.cycle_center_id
               ]
             }
      end
      it "returns created survey in json format" do
        expect(response.content_type).to eq "application/json"
      end
      it "the response has the correct content" do
        expect(json).to include "saved"
        expect(json).to include "survey"
        expect(json["saved"]).to eq true
        expect(json["survey"]["status"]).to eq "Receiving Feedback"
      end
    end
    context "when admin creates survey without cycles" do
      before do
        post  :create,
              params: { survey: build(:survey) }
      end
      it "the response has the correct content" do
        expect(json).to include "errors"
        expect(json["saved"]).to eq false
        expect(json["errors"]["recipients"]).to eq ["must be provided"]
      end
    end

    context "when admin creates survey with wrong url" do
      before do
        post  :create,
              params: {
                survey: build(:survey, with_wrong_link: true).attributes,
                recipients: [
                  @cycle_center1.cycle_center_id,
                  @cycle_center2.cycle_center_id
                ]
              }
      end
      it "the response has the correct content" do
        errors = json["errors"]["link"]
        expect(errors).to eq ["must be a valid http:// or https://"]
        expect(json["saved"]).to eq false
        expect(json).to include "errors"
      end
    end

    context "when admin creates survey with empty title and link" do
      before do
        post  :create,
              params: {
                survey: build(:survey, with_empty_fields: true).attributes,
                recipients: [
                  @cycle_center1.cycle_center_id,
                  @cycle_center2.cycle_center_id
                ]
              }
      end
      it "the response has the correct content" do
        expect(json).to include "errors"
        errors = json["errors"]
        link_errors = ["can't be blank", "must be a valid http:// or https://"]
        expect(errors["link"]).to eq link_errors
        expect(errors["title"]).to eq ["can't be blank"]
        expect(json["saved"]).to eq false
      end
    end
  end

  describe "PUT #update" do
    context "when admin updates survey with valid payload" do
      before do
        put :update,
            params: {
              id: survey.survey_id,
              survey: build(:survey, with_update_fields: true).attributes,
              recipients: [
                @cycle_center2.cycle_center_id
              ]
            }
      end
      it "returns Updated survey in json format" do
        expect(response.content_type).to eq "application/json"
      end
      it "the response has the correct content" do
        expect(json["survey"]["title"]).to eq "Test survey"
        expect(json["survey"]["survey_id"]).to eq survey.survey_id
        expect(json["survey"]["link"]).to eq "https://www.vof.andela.com"
        expect(json["saved"]).to eq true
      end
    end
    context "when admin updates survey with invalid payload" do
      before do
        put :update,
            params: {
              id: survey.survey_id,
              survey: build(:survey, with_wrong_link: true).attributes,
              recipients: [
                @cycle_center2.cycle_center_id
              ]
            }
      end
      it "returns alerts wrong link used " do
        expect(json).to include "errors"
        link_errors = ["must be a valid http:// or https://"]
        expect(json["errors"]["link"]).to eq link_errors
      end
    end
  end

  describe "PUT #close" do
    before do
      stub_current_user(:user)
      @survey = create(:survey)
    end

    context "when admin closes a survey that exist" do
      before do
        put  :close,
             params: {
               id: @survey.survey_id
             }
      end
      it "the response has the correct content" do
        expect(json["saved"]).to eq true
        expect(json["survey"]["status"]).to eq "Completed"
      end
    end
    context "when admin closes a survey that doesn't exist" do
      before do
        put  :close,
             params: {
               id: "-LRkiXwqZi9y2NKTFIJL"
             }
      end
      it "the response has the correct content" do
        expect(json).to include "saved"
        expect(json).to include "errors"
        expect(json["saved"]).to eq false
        expect(json["errors"]).to eq "Survey not found"
      end
    end
  end
end
