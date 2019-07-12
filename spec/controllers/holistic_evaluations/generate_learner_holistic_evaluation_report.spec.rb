require "rails_helper"
require "helpers/holistic_evaluation_helpers"

RSpec.describe HolisticEvaluationsController, type: :controller do
  let(:user) { create :user }
  let(:criterium) { create :criterium }
  let(:learner_program) { create :learner_program }
  let(:holistic_evaluation_average) { create :holistic_evaluation_average }

  let(:csv_filename) { { filename: "bootcampers-#{Date.today}.csv" } }
  let(:csv_header) do
    BootcampersCsvService.generate_holistic_evaluation_report(
      HolisticEvaluationHelpers.evaluation_details, learner_program.bootcamper
    )
  end

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    create(
      :holistic_evaluation,
      learner_program_id: learner_program.id,
      criterium_id: criterium.id,
      holistic_evaluation_average_id: holistic_evaluation_average.id
    )
    get :generate_learner_holistic_evaluation_report, params: {
      learner_program_id: learner_program.id,
      format: "csv",
      camper_id: learner_program.camper_id
    }
  end

  after :all do
    HolisticEvaluation.delete_all
  end

  describe "#generate_learner_holistic_evaluation_report" do
    it "has access to the send_data method" do
      expect(controller).to receive(:send_data).
        with(csv_filename, csv_header)
      controller.send_data(csv_filename, csv_header)
    end

    it "returns text/csv headers" do
      expect(response.headers["Content-Type"]).to include "text/csv"
    end

    it "returns learner's name in the csv file" do
      camper = learner_program.bootcamper
      header_text = "Holistic Evaluation Performance for"
      expect(
        response.body
      ).to include "#{header_text} #{camper.first_name} #{camper.last_name}"
    end
  end
end
