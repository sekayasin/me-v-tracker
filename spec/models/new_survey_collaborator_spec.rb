require "rails_helper"

RSpec.describe NewSurveyCollaborator, type: :model do
  describe "Association" do
    it { should belong_to(:new_survey) }
    it { should belong_to(:collaborator) }
  end
  describe "Validations" do
    it { validate_presence_of(:collaborator_id) }
    it { validate_presence_of(:new_survey_id) }
  end
end
