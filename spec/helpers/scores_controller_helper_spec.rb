require "rails_helper"
require_relative "../support/helpers/score_controller_helper.rb"

RSpec.describe ScoresControllerHelper, type: :helper do
  include ScoreControllerHelper
  let(:phases) { build_list(:phase, 8, name: "Bootcamp") }
  describe "get_current_phase" do
    it "returns the current phase for the day" do
      current_phase = get_current_phase(nil, transform(phases), Date.today)
      expect(current_phase).to be_an_instance_of(Hash)
      expect(current_phase.length).to eq(1)
      phases_key = current_phase.values.any? do |phase|
        phase[:title] && phase[:index]
      end
      expect(phases_key).to eq(true)
      expect(current_phase.values.first).to include(title: "Bootcamp")
    end
  end

  describe "set dates method" do
    it "returns an empty object when sent an invalid date" do
      return_hash = set_date({ invalid_date: "result" }, [])
      expect(return_hash).to eq({})
      expect(return_hash).to be_an_instance_of(Hash)
      expect(return_hash.keys.length).to eq(0)
    end

    it "returns the correct phase when sent a valid date" do
      work_date = 2.business_days.ago.to_s
      phases_hash = {}
      phases_hash[work_date] = {}
      set_date(phases_hash, [12, "On boarding"])
      expect(phases_hash).to be_an_instance_of(Hash)
      expect(phases_hash.keys.include?(work_date.to_s)).to eq(true)
    end
  end

  describe "Initialize start date method" do
    it "returns an empty object when sent an invalid date" do
      response = initialize_start_date({}, {}, "invalid date")
      expect(response).to eq({})
      expect(response).to be_an_instance_of(Hash)
      expect(response.keys.length).to eq(0)
    end

    it "returns the correct date when called with the right date" do
      today = Date.today.to_s
      phases_hash = {}
      mock_phase = [10, "Self Learning"]
      initialize_start_date(phases_hash, mock_phase, today)
      expect(phases_hash[today][:title]).to eq("Self Learning")
      expect(phases_hash[today][:index]).to eq(10)
    end
  end
end
