require "rails_helper"
require "spec_helper"

RSpec.describe ScheduleFeedbackController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:user) { create :user }

  before do
    stub_current_user :user
    @program = Program.first
    @cycle_center = create(:cycle_center, program_id: @program.id)
    @nps_question1_id = create(:nps_question).nps_question_id
    @nps_question2_id = create(:nps_question).nps_question_id
    @start_date = @cycle_center.start_date
    @end_date = @cycle_center.end_date
    @cycle_id = @cycle_center.cycle_id
    @center_id = @cycle_center.center_id
  end

  describe "post #save_feedback_schedule" do
    context "when admin schedules with invalid cycle/center details " do
      before do
        post :save_feedback_schedule,
             params: {
               schedule_feedback: {
                 program: @program,
                 cycle_id: "random",
                 center_id: "random",
                 nps_question_id: @nps_question2,
                 start_date: @start_date,
                 end_date: @start_date
               }
             }
      end

      it "does not save with invalid cycle/center details" do
        expect(json).to include "errors"
        expect(json["saved"]).to eq false
        expect(json["errors"]).to eq "Invalid cycle/center details"
      end
    end

    context "when admin schedules with valid details " do
      before do
        post :save_feedback_schedule,
             params: {
               program: @program,
               cycle_id: @cycle_id,
               center_id: @center_id,
               nps_question_id: @nps_question2_id,
               start_date: @start_date,
               end_date: @end_date
             }
      end

      it "saves with valid details" do
        expect(json["saved"]).to eq true
      end
      it "returns schedule feedback in json format" do
        expect(response.content_type).to eq "application/json"
      end
      it "returns program" do
        expect(json["feedback_schedule"]).to include "program_id"
      end
      it "returns cycle" do
        expect(json["feedback_schedule"]).to include "cycle_center_id"
      end
      it "returns program feedback question" do
        expect(json["feedback_schedule"]).to include "nps_question_id"
      end
      it "returns start date" do
        expect(json["feedback_schedule"]).to include "start_date"
      end
      it "returns end date" do
        expect(json["feedback_schedule"]).to include "end_date"
      end
    end

    context "when admin schedules with invalid details " do
      before do
        post :save_feedback_schedule,
             params: {
               cycle_id: @cycle_id,
               center_id: @center_id
             }
      end

      it "saves with valid details" do
        expect(json["saved"]).to eq false
        expect(json).to include "errors"
        expect(json["errors"]).to eq "An error occured."
      end
      it "returns schedule feedback in json format" do
        expect(response.content_type).to eq "application/json"
      end
    end
  end
end
