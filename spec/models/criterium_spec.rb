require "rails_helper"

RSpec.describe Criterium, type: :model do
  describe "Validations" do
    it { is_expected.to have_many(:frameworks).through(:framework_criteria) }
    it { is_expected.to have_many(:holistic_evaluations) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe ".get_program_criteria" do
    include_context "program criteria context"
    it "returns the program criteria" do
      criterium_data = Criterium.get_program_criteria(program.id)
      expect(criterium_data.length).to eql(1)
      expect(criterium_data[0][:name]).to eql(criterium.name)
      expect(criterium_data[0][:id]).to eql(criterium.id)
    end
  end

  describe ".get_criteria_for_specific_program" do
    let(:program) { Program.first }

    it "returns the program dependent criteria" do
      expect(Criterium.get_criteria_for_program(program.id).
        length).to be >= 1
    end
  end

  describe ".get_program_criteria_for_assessment" do
    let(:program) { Program.first }

    it "returns the program criteria for assessements" do
      expect(Criterium.get_program_criteria_for_assessment(program.id).length).
        to be >= 1
    end
  end

  describe ".get_all_criteria" do
    it "returns all criteria" do
      expect(Criterium.get_all_criteria.length).to eq Criterium.all.length
    end
  end

  describe ".search" do
    context "when results match the search term" do
      it "returns criteria that matches the search term" do
        search_term = "EPIC"
        expect(Criterium.search(search_term, 1).length).to eq(1)
      end
    end

    context "when results do not match the search term" do
      it "returns empty result" do
        search_term = "axz33hJnf"
        expect(Criterium.search(search_term, 1).length).to eq(0)
      end
    end
  end

  describe "criteria description update" do
    it "returns all criteria descriptions" do
      expect(Criterium.criteria_descriptions).to include "Output Quality"
    end
  end

  describe "output quality description" do
    it "returns all output_quality descriptions" do
      expect(Criterium.output_quality_criteria).to be
    end
  end

  describe "Values alignment descriptions" do
    it "returns all values alignment descriptions" do
      expect(Criterium.values_alignment_criteria).to be
    end
  end

  describe "feedback descriptions" do
    it "returns all feedback descriptions" do
      expect(Criterium.feedback_criteria).to be
    end
  end
end
