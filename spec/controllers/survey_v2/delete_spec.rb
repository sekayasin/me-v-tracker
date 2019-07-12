require "rails_helper"

RSpec.describe SurveysV2Controller, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:new_survey) { create(:new_survey) }

  describe "DELETE #destroy" do
    before do
      stub_current_user(:admin)
    end
    context "Delete a survey" do
      it "successfully delete a survey" do
        delete :destroy, params: {
          id: new_survey.id
        }
        expect(response).not_to be_nil
        expect(response.body).to include("Survey deleted successfully")
        expect(response.status).to eq(200)
        expect(NewSurvey.last.present?).to be(false)
      end

      it "fails to delete a survey with invalid id" do
        delete :destroy, params: {
          id: "thisisafakeid"
        }
        expect(response.body).to include("Couldn't find NewSurvey")
        expect(response.status).to eq(404)
      end
    end
  end
end
