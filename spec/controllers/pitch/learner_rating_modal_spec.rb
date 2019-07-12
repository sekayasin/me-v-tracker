require "rails_helper"
require_relative "../../helpers/panelist_get_all_learners_controller_helper.rb"

RSpec.describe PitchController, type: :controller do
  let(:user) { create :user }

  before(:each) do
    pitch_create_program_helper
    pitch_panelist_create
  end

  after(:each) do
    pitch_destroy_helper
  end

  describe "GET all ratings for a learner" do
    it "returns learners in active cycles" do
      get :show_learner_ratings,
          params: { learners_pitch_id: @learners_pitch .id }
      expect(response.status).to eq(200)
    end
  end
end
