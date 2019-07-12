require "rails_helper"

RSpec.describe Collaborator, type: :model do
  describe "Association" do
    it { should have_many(:new_surveys) }
    it { should have_many(:new_survey_collaborators) }
  end
  describe "Validations" do
    it { should validate_presence_of(:email) }
  end
end
